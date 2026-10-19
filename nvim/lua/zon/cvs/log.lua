-- cvs log: parse, cache, and the file history picker.
local run = require('zon.cvs.run')
local entries = require('zon.cvs.entries')

local M = {}

local FILE_SEP = '============================================================================='
local REV_SEP = '----------------------------'

local function parse_date(s)
    -- 2025-11-17 16:32:41 +0200  or  2008/06/03 10:22:01
    local Y, Mo, D, h, mi, sec = s:match('(%d+)[-/](%d+)[-/](%d+) (%d+):(%d+):(%d+)')
    if not Y then return nil end
    return os.time({ year = Y, month = Mo, day = D, hour = h, min = mi, sec = sec })
end

-- Parse `cvs log` output for one file -> { commits = { {rev, date, ts, author, ...} }, by_rev = {} }
function M.parse(lines)
    local commits, by_rev = {}, {}
    local cur
    local i = 1
    -- skip the header until the first revision separator
    while i <= #lines and lines[i] ~= REV_SEP do
        i = i + 1
    end
    while i <= #lines do
        local l = lines[i]
        if l == REV_SEP or l == FILE_SEP then
            if cur then
                table.insert(commits, cur)
                by_rev[cur.rev] = cur
            end
            cur = nil
            if l == FILE_SEP then break end
            local rev = (lines[i + 1] or ''):match('^revision ([%d%.]+)')
            if rev then
                cur = { rev = rev, message = {} }
                local meta = lines[i + 2] or ''
                for k, v in meta:gmatch('(%a+):%s+([^;]+);') do
                    cur[k] = vim.trim(v)
                end
                cur.ts = cur.date and parse_date(cur.date)
                cur.day = ((cur.date or ''):match('^(%d+[-/]%d+[-/]%d+)') or ''):gsub('/', '-')
                i = i + 3
                if (lines[i] or ''):match('^branches:') then i = i + 1 end
            else
                i = i + 1
            end
        else
            if cur then table.insert(cur.message, l) end
            i = i + 1
        end
    end
    for _, c in ipairs(commits) do
        while #c.message > 0 and c.message[#c.message] == '' do
            table.remove(c.message)
        end
        c.title = c.message[1] or ''
    end
    return { commits = commits, by_rev = by_rev }
end

local mem = {} -- path -> { rev, time, log }
local TTL = 600

-- cb(log | nil, err). Cached in memory per file + base revision for 10 min.
function M.get(info, cb, opts)
    local c = mem[info.path]
    if c and c.rev == info.rev and os.time() - c.time < TTL and not (opts and opts.force) then
        return cb(c.log)
    end
    run.run({ 'log', info.name }, { cwd = info.dir }, function(ok, out, err)
        if not ok then return cb(nil, vim.trim(err)) end
        local log = M.parse(run.lines(out))
        mem[info.path] = { rev = info.rev, time = os.time(), log = log }
        cb(log)
    end)
end

-- 1.42 -> 1.41; 1.2.4.1 -> 1.2; 1.1 -> nil
function M.prior(rev)
    local head, n = rev:match('^(.*)%.(%d+)$')
    if not head then return nil end
    n = tonumber(n)
    if n > 1 then return head .. '.' .. (n - 1) end
    local base = head:match('^(.*)%.%d+$')
    if base and base:find('.', 1, true) then return base end
    return nil
end

function M.format_commit(c)
    local out = { ('%s  %s  %s'):format(c.rev, c.author or '?', c.date or '?') }
    if c.commitid then out[1] = out[1] .. '  ' .. c.commitid end
    table.insert(out, '')
    vim.list_extend(out, c.message)
    return out
end

-- File history picker (fzf-lua). Enter: diff rev against its prior rev.
function M.history(path)
    path = path or vim.api.nvim_buf_get_name(0)
    local info = entries.info(path)
    if not info or not info.rev then return vim.notify('Not a CVS file', vim.log.levels.WARN) end
    vim.notify('cvs log ' .. info.name .. ' ...')
    M.get(info, function(log, err)
        if not log then
            return vim.notify('cvs log failed: ' .. (err or ''), vim.log.levels.ERROR)
        end
        local items, by_line = {}, {}
        for _, c in ipairs(log.commits) do
            local line = ('%-9s %s  %-12s %s'):format(c.rev, c.day or '', c.author or '', c.title)
            table.insert(items, line)
            by_line[c.rev] = c
        end
        local function commit_of(sel)
            local rev = sel and sel:match('^(%S+)')
            return rev and by_line[rev]
        end
        local fzf = require('fzf-lua')
        fzf.fzf_exec(items, {
            prompt = 'CVS log ' .. info.name .. '> ',
            fzf_opts = { ['--no-sort'] = true },
            preview = {
                type = 'cmd',
                fn = function(sel)
                    local c = commit_of(sel[1])
                    if not c then return 'true' end
                    local msg = table.concat(M.format_commit(c), '\n')
                    local prior = M.prior(c.rev)
                    local diff = prior
                            and ('cvs -f -Q diff -u -r %s -r %s %s'):format(
                                prior,
                                c.rev,
                                vim.fn.shellescape(info.name)
                            )
                        or 'true'
                    return ('cd %s && printf "%%s\\n\\n" %s && %s'):format(
                        vim.fn.shellescape(info.dir),
                        vim.fn.shellescape(msg),
                        diff
                    )
                end,
            },
            actions = {
                ['enter'] = function(sel)
                    local c = commit_of(sel[1])
                    if c then
                        local prior = M.prior(c.rev)
                        require('zon.cvs.diff').revs(info.path, prior or '0', c.rev)
                    end
                end,
                ['ctrl-o'] = function(sel)
                    local c = commit_of(sel[1])
                    if c then require('zon.cvs.diff').open_rev(info.path, c.rev) end
                end,
                ['ctrl-y'] = function(sel)
                    local c = commit_of(sel[1])
                    if c then
                        vim.fn.setreg('+', c.rev)
                        vim.notify('Yanked ' .. c.rev)
                    end
                end,
            },
        })
    end)
end

return M
