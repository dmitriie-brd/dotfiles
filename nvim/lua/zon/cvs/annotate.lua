-- CVS annotate with full author names (idea from mrchnk/cvs.nvim sys/annotate.lua).
-- `cvs annotate` cuts user names to 8 chars and shows only the day, so we also run
-- `cvs log` and join both by revision: full author, exact date, commit message.
--
--   open():  narrow split on the left, scroll- and cursor-bound to the file.
--            <CR> re-annotate at the line's revision   ^  at the revision before it
--            <BS> go back                               d  diff of that revision
--            <Tab>/<S-Tab> next/prev block of the same revision
--            K  commit message                          q  close
--   blame(): float with the commit for the cursor line.
local run = require('zon.cvs.run')
local entries = require('zon.cvs.entries')
local cvs_log = require('zon.cvs.log')
local cache = require('zon.cvs.cache')

local M = {}

local ns = vim.api.nvim_create_namespace('cvs_annotate')
local AGES = 5

local function set_hl()
    local links = { 'Comment', 'Function', 'String', 'DiagnosticWarn', 'DiagnosticError' }
    for i, l in ipairs(links) do
        vim.api.nvim_set_hl(0, 'CvsAge' .. i, { link = l, default = true })
    end
    vim.api.nvim_set_hl(0, 'CvsAuthor', { link = 'Identifier', default = true })
    vim.api.nvim_set_hl(0, 'CvsRev', { link = 'Number', default = true })
    vim.api.nvim_set_hl(0, 'CvsLocal', { link = 'DiagnosticHint', default = true })
end
set_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })

----------------------------------------
-- Data
----------------------------------------
local PATTERN = '^([%d%.]+)%s+%((%S+)%s+(%d%d%-%a%a%a%-%d%d)%): ?(.*)$'

local function parse(lines)
    local res = {}
    for _, l in ipairs(lines) do
        local rev, author, date, text = l:match(PATTERN)
        if rev then table.insert(res, { rev = rev, author = author, date = date, text = text }) end
    end
    return res
end

local mem = {} -- path@rev -> meta (revision content never changes)

-- cb(meta | nil, err); meta[i] = { rev, author, date, ts, commit, text }
function M.fetch(info, rev, cb)
    local key = info.path .. '@' .. rev
    if mem[key] then return cb(mem[key]) end
    local got, ann, log, err = 0, nil, nil, nil
    local function done()
        got = got + 1
        if got < 2 then return end
        if not ann then return cb(nil, err) end
        local meta = {}
        for _, a in ipairs(ann) do
            local c = log and log.by_rev[a.rev]
            table.insert(meta, {
                rev = a.rev,
                author = c and c.author or a.author,
                date = c and c.day or a.date,
                ts = c and c.ts or 0,
                commit = c,
                text = a.text,
            })
        end
        mem[key] = meta
        cb(meta)
    end
    run.run({ 'annotate', '-r', rev, info.name }, { cwd = info.dir }, function(ok, out, e)
        if ok then
            ann = parse(run.lines(out))
        else
            err = vim.trim(e)
        end
        done()
    end)
    cvs_log.get(info, function(l)
        log = l
        done()
    end)
end

-- Align annotate lines with the buffer text (local edits get { local_change = true }).
function M.align(meta, buf_lines)
    local a = table.concat(vim.tbl_map(function(m) return m.text end, meta), '\n') .. '\n'
    local b = table.concat(buf_lines, '\n') .. '\n'
    local hunks = vim.text.diff(a, b, { result_type = 'indices', algorithm = 'histogram' })
    local out, ia = {}, 1
    for _, h in ipairs(hunks) do
        local sa, ca, _, cb = unpack(h)
        local last = ca > 0 and sa - 1 or sa
        for k = ia, last do
            table.insert(out, meta[k])
        end
        for _ = 1, cb do
            table.insert(out, { local_change = true })
        end
        ia = ca > 0 and sa + ca or sa + 1
    end
    for k = ia, #meta do
        table.insert(out, meta[k])
    end
    return out
end

local function ages(meta)
    local lo, hi
    for _, m in ipairs(meta) do
        if m.ts and m.ts > 0 then
            lo = math.min(lo or m.ts, m.ts)
            hi = math.max(hi or m.ts, m.ts)
        end
    end
    return function(ts)
        if not ts or ts == 0 or not lo then return 1 end
        if hi == lo then return AGES end
        return math.min(AGES, math.floor((ts - lo) / (hi - lo + 1) * AGES) + 1)
    end
end

local function file_info(buf)
    local cf = vim.b[buf].cvs_file
    local path = cf and cf.path or vim.api.nvim_buf_get_name(buf)
    local info = entries.info(path)
    if not info or not info.rev or info.rev == '0' then return nil end
    return info, cf and cf.rev or info.rev
end

----------------------------------------
-- Line blame (float)
----------------------------------------
function M.blame()
    local buf = vim.api.nvim_get_current_buf()
    local info, rev = file_info(buf)
    if not info then return vim.notify('Not a committed CVS file', vim.log.levels.WARN) end
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    M.fetch(info, rev, function(meta, err)
        if not meta then
            return vim.notify('cvs annotate failed: ' .. (err or ''), vim.log.levels.ERROR)
        end
        local aligned = M.align(meta, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
        local m = aligned[lnum]
        local lines
        if not m or m.local_change then
            lines = { 'Not committed yet (local change)' }
        elseif m.commit then
            lines = cvs_log.format_commit(m.commit)
        else
            lines = { ('%s  %s  %s'):format(m.rev, m.author, m.date) }
        end
        vim.lsp.util.open_floating_preview(
            lines,
            'text',
            { focus_id = 'cvs_blame', max_width = 100 }
        )
    end)
end

----------------------------------------
-- Annotate split
----------------------------------------
local State = {}
State.__index = State

local function render(self)
    local buf_lines = vim.api.nvim_buf_get_lines(self.src_buf, 0, -1, false)
    self.meta = M.align(self.raw, buf_lines)
    local age = ages(self.meta)
    local wa, wr = 0, 0
    for _, m in ipairs(self.meta) do
        if not m.local_change then
            wa = math.max(wa, #m.author)
            wr = math.max(wr, #m.rev)
        end
    end
    local fmt = '%-' .. wa .. 's %-' .. wr .. 's %s'
    local lines, width = {}, 0
    for i, m in ipairs(self.meta) do
        lines[i] = m.local_change and 'Not committed' or fmt:format(m.author, m.rev, m.date)
        width = math.max(width, #lines[i])
    end
    local ab = self.ann_buf
    vim.bo[ab].modifiable = true
    vim.api.nvim_buf_set_lines(ab, 0, -1, false, lines)
    vim.bo[ab].modifiable = false
    vim.api.nvim_buf_clear_namespace(ab, ns, 0, -1)
    local function hl(row, c1, c2, group)
        vim.api.nvim_buf_set_extmark(ab, ns, row, c1, { end_col = c2, hl_group = group })
    end
    for i, m in ipairs(self.meta) do
        local len = #lines[i]
        if m.local_change then
            hl(i - 1, 0, len, 'CvsLocal')
        else
            m.age = age(m.ts)
            hl(i - 1, 0, wa, 'CvsAuthor')
            hl(i - 1, wa + 1, wa + 1 + wr, 'CvsRev')
            hl(i - 1, wa + wr + 2, len, 'CvsAge' .. m.age)
        end
    end
    vim.api.nvim_win_set_width(self.ann_win, width + 1)
    self.sign_rev = nil
end

local function cur_meta(self)
    local lnum = vim.api.nvim_win_get_cursor(self.src_win)[1]
    return self.meta[lnum], lnum
end

local function update_signs(self)
    local m = cur_meta(self)
    local rev = m and not m.local_change and m.rev or nil
    if rev == self.sign_rev then return end
    self.sign_rev = rev
    vim.api.nvim_buf_clear_namespace(self.src_buf, ns, 0, -1)
    if rev then
        for i, x in ipairs(self.meta) do
            if x.rev == rev then
                vim.api.nvim_buf_set_extmark(self.src_buf, ns, i - 1, 0, {
                    sign_text = '┃',
                    sign_hl_group = 'CvsAge' .. (x.age or 1),
                    priority = 300,
                })
            end
        end
        if m.commit then
            vim.api.nvim_echo(
                { { ('%s %s: %s'):format(m.rev, m.author, m.commit.title), 'Comment' } },
                false,
                {}
            )
        end
    end
end

local function set_win_opts(win, opts)
    for k, v in pairs(opts) do
        vim.wo[win][k] = v
    end
end

local BIND = { scrollbind = true, cursorbind = true, wrap = false, foldenable = false }

function State:show(buf, rev, raw, lnum)
    vim.api.nvim_buf_clear_namespace(self.src_buf, ns, 0, -1)
    self.src_buf = buf
    self.rev = rev
    self.raw = raw
    vim.api.nvim_win_set_buf(self.src_win, buf)
    set_win_opts(self.src_win, BIND)
    render(self)
    lnum = math.max(1, math.min(lnum or 1, vim.api.nvim_buf_line_count(buf)))
    vim.api.nvim_win_set_cursor(self.src_win, { lnum, 0 })
    vim.api.nvim_win_set_cursor(self.ann_win, { lnum, 0 })
    vim.api.nvim_win_call(self.ann_win, function() vim.cmd('syncbind') end)
    update_signs(self)
end

-- Re-annotate the file at another revision (keeps a back stack).
function State:goto_rev(rev, near)
    if not rev or rev == self.rev then return end
    local _, lnum = cur_meta(self)
    table.insert(self.stack, { buf = self.src_buf, rev = self.rev, raw = self.raw, lnum = lnum })
    vim.notify('cvs annotate -r ' .. rev .. ' ...')
    cache.get(self.info, rev, function(lines, err)
        if not lines then
            table.remove(self.stack)
            return vim.notify('cvs: ' .. (err or 'fetch failed'), vim.log.levels.ERROR)
        end
        M.fetch(self.info, rev, function(raw, e)
            if not raw then
                table.remove(self.stack)
                return vim.notify('cvs annotate failed: ' .. (e or ''), vim.log.levels.ERROR)
            end
            local buf = require('zon.cvs.diff').rev_buf(self.info, rev, lines)
            vim.bo[buf].bufhidden = 'hide'
            -- Try to keep the cursor on the same line of code.
            local target = lnum
            if near then
                for i, x in ipairs(raw) do
                    if x.rev == near.rev and x.text == near.text then
                        target = i
                        break
                    end
                end
            end
            self:show(buf, rev, raw, target)
        end)
    end)
end

function State:back()
    local prev = table.remove(self.stack)
    if prev then self:show(prev.buf, prev.rev, prev.raw, prev.lnum) end
end

function State:jump_block(dir)
    local m, lnum = cur_meta(self)
    if not m or m.local_change then return end
    local i, left = lnum + dir, false
    while i >= 1 and i <= #self.meta do
        local x = self.meta[i]
        if x.rev ~= m.rev then
            left = true
        elseif left then
            vim.cmd("normal! m'")
            vim.api.nvim_win_set_cursor(self.ann_win, { i, 0 })
            return
        end
        i = i + dir
    end
end

function State:close()
    if self.closed then return end
    self.closed = true
    pcall(vim.api.nvim_del_augroup_by_id, self.group)
    if vim.api.nvim_win_is_valid(self.src_win) then
        if self.src_buf ~= self.orig_buf and vim.api.nvim_buf_is_valid(self.orig_buf) then
            vim.api.nvim_win_set_buf(self.src_win, self.orig_buf)
        end
        set_win_opts(self.src_win, self.saved)
    end
    for _, b in ipairs({ self.src_buf, self.orig_buf }) do
        if vim.api.nvim_buf_is_valid(b) then vim.api.nvim_buf_clear_namespace(b, ns, 0, -1) end
    end
    if vim.api.nvim_win_is_valid(self.ann_win) then vim.api.nvim_win_close(self.ann_win, true) end
    if vim.api.nvim_buf_is_valid(self.ann_buf) then
        vim.api.nvim_buf_delete(self.ann_buf, { force = true })
    end
end

local function setup_keys(self)
    local function map(lhs, fn, desc)
        vim.keymap.set(
            'n',
            lhs,
            fn,
            { buffer = self.ann_buf, nowait = true, silent = true, desc = desc }
        )
    end
    map('<CR>', function()
        local m = cur_meta(self)
        if m and not m.local_change then self:goto_rev(m.rev, m) end
    end, 'Annotate at this revision')
    map('^', function()
        local m = cur_meta(self)
        if m and not m.local_change then self:goto_rev(cvs_log.prior(m.rev)) end
    end, 'Annotate at the revision before this one')
    map('<BS>', function() self:back() end, 'Back')
    map('<Tab>', function() self:jump_block(1) end, 'Next block of the same revision')
    map('<S-Tab>', function() self:jump_block(-1) end, 'Previous block of the same revision')
    map('d', function()
        local m = cur_meta(self)
        if m and not m.local_change then
            require('zon.cvs.diff').revs(self.info.path, cvs_log.prior(m.rev) or '0', m.rev)
        end
    end, 'Diff this revision against its prior')
    map('K', function()
        local m = cur_meta(self)
        if m and m.commit then
            vim.lsp.util.open_floating_preview(
                cvs_log.format_commit(m.commit),
                'text',
                { focus_id = 'cvs_commit' }
            )
        end
    end, 'Show commit message')
    map('q', function() self:close() end, 'Close annotate')
end

local active = {} -- src_win -> state

function M.open()
    local src_win = vim.api.nvim_get_current_win()
    if active[src_win] and not active[src_win].closed then return active[src_win]:close() end
    local src_buf = vim.api.nvim_get_current_buf()
    local info, rev = file_info(src_buf)
    if not info then return vim.notify('Not a committed CVS file', vim.log.levels.WARN) end
    vim.notify('cvs annotate ' .. info.name .. ' ...')
    M.fetch(info, rev, function(raw, err)
        if not raw then
            return vim.notify('cvs annotate failed: ' .. (err or ''), vim.log.levels.ERROR)
        end
        if not vim.api.nvim_win_is_valid(src_win) then return end
        local self = setmetatable({
            info = info,
            src_win = src_win,
            src_buf = src_buf,
            orig_buf = src_buf,
            stack = {},
            saved = {},
        }, State)
        for k in pairs(BIND) do
            self.saved[k] = vim.wo[src_win][k]
        end
        self.ann_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[self.ann_buf].filetype = 'cvsannotate'
        vim.api.nvim_win_call(src_win, function()
            vim.cmd('leftabove vsplit')
            self.ann_win = vim.api.nvim_get_current_win()
        end)
        vim.api.nvim_win_set_buf(self.ann_win, self.ann_buf)
        set_win_opts(self.ann_win, {
            number = false,
            relativenumber = false,
            signcolumn = 'no',
            foldcolumn = '0',
            list = false,
            spell = false,
            colorcolumn = '',
            winfixwidth = true,
            cursorline = true,
            scrollbind = true,
            cursorbind = true,
            wrap = false,
            foldenable = false,
            statusline = ' CVS annotate',
        })
        setup_keys(self)
        self.group = vim.api.nvim_create_augroup('CvsAnnotate' .. self.ann_buf, { clear = true })
        vim.api.nvim_create_autocmd('WinClosed', {
            group = self.group,
            callback = function(ev)
                local w = tonumber(ev.match)
                if w == self.ann_win or w == self.src_win then
                    vim.schedule(function() self:close() end)
                end
            end,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
            group = self.group,
            callback = function()
                local w = vim.api.nvim_get_current_win()
                if w == self.ann_win or w == self.src_win then update_signs(self) end
            end,
        })
        vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
            group = self.group,
            callback = function(ev)
                if ev.buf == self.src_buf then
                    render(self)
                    update_signs(self)
                end
            end,
        })
        active[src_win] = self
        self:show(src_buf, rev, raw, vim.api.nvim_win_get_cursor(src_win)[1])
        vim.api.nvim_set_current_win(self.ann_win)
    end)
end

return M
