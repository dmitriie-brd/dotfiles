-- CVS diff views (company vimrc `rjd` / :CVSVimDiff, improved).
--   open(path, 'BASE'|'HEAD'|rev): new tab, left = repository version (read-only), right = your file.
--   revs(path, r1, r2):            new tab, two repository versions.
--   open_rev(path, rev):           show the file at a revision in the current window.
-- In the diff tab: ]c [c (or Tab S-Tab) move, do dp get/put, q closes the tab.
local entries = require('zon.cvs.entries')
local cache = require('zon.cvs.cache')

local M = {}

local function rev_buf(info, rev, lines)
    local name = ('cvs://%s/%s@%s'):format(info.repo, info.name, rev)
    local buf = vim.fn.bufnr(name)
    if buf > 0 and vim.api.nvim_buf_is_loaded(buf) then return buf end
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, name)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = 'wipe'
    local ft = vim.filetype.match({ filename = info.name, buf = buf })
    if ft then vim.bo[buf].filetype = ft end
    vim.b[buf].cvs_file = { path = info.path, rev = rev }
    vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = buf, desc = 'Close CVS diff tab' })
    return buf
end
M.rev_buf = rev_buf

local function resolve(info, which)
    if which == 'BASE' or which == nil then return info.rev end
    return which
end

local function current_info(path)
    path = path or vim.api.nvim_buf_get_name(0)
    local cf = vim.b.cvs_file
    if cf then path = cf.path end
    local info = entries.info(path)
    if not info or not info.rev then
        vim.notify('Not a CVS file: ' .. path, vim.log.levels.WARN)
        return nil
    end
    return info
end

function M.open(path, which)
    local info = current_info(path)
    if not info then return end
    local rev = resolve(info, which)
    vim.notify(('cvs: fetching %s@%s ...'):format(info.name, rev))
    cache.get(info, rev, function(lines, err)
        if not lines then
            return vim.notify('cvs update -p failed: ' .. (err or ''), vim.log.levels.ERROR)
        end
        vim.cmd('tabedit ' .. vim.fn.fnameescape(info.path))
        local right = vim.api.nvim_get_current_win()
        vim.cmd('leftabove vsplit')
        vim.api.nvim_win_set_buf(0, rev_buf(info, rev, lines))
        vim.cmd('diffthis')
        vim.api.nvim_set_current_win(right)
        vim.cmd('diffthis')
        vim.cmd('normal! gg]c')
    end)
end

function M.revs(path, r1, r2)
    local info = current_info(path)
    if not info then return end
    local got, left_lines, right_lines = 0, nil, nil
    local function done()
        got = got + 1
        if got < 2 then return end
        if not left_lines or not right_lines then
            return vim.notify('cvs: failed to fetch revisions', vim.log.levels.ERROR)
        end
        vim.cmd('tabnew')
        local scratch = vim.api.nvim_get_current_buf()
        vim.api.nvim_win_set_buf(0, rev_buf(info, r2, right_lines))
        vim.cmd('diffthis')
        local right = vim.api.nvim_get_current_win()
        vim.cmd('leftabove vsplit')
        vim.api.nvim_win_set_buf(0, rev_buf(info, r1, left_lines))
        vim.cmd('diffthis')
        vim.api.nvim_set_current_win(right)
        if vim.api.nvim_buf_is_valid(scratch) then
            vim.api.nvim_buf_delete(scratch, { force = true })
        end
        pcall(vim.cmd, 'normal! gg]c')
    end
    cache.get(info, r1, function(l)
        left_lines = l
        done()
    end)
    cache.get(info, r2, function(l)
        right_lines = l
        done()
    end)
end

function M.open_rev(path, rev, cb)
    local info = current_info(path)
    if not info then return end
    cache.get(info, rev, function(lines, err)
        if not lines then
            return vim.notify('cvs update -p failed: ' .. (err or ''), vim.log.levels.ERROR)
        end
        local buf = rev_buf(info, rev, lines)
        vim.keymap.set(
            'n',
            'q',
            '<cmd>bdelete<CR>',
            { buffer = buf, desc = 'Close revision buffer' }
        )
        if cb then return cb(buf) end
        vim.api.nvim_win_set_buf(0, buf)
    end)
end

return M
