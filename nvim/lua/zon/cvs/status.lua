-- CVS status.
--   scan(root, cb): local, offline scan of CVS/Entries + file mtimes (fast, ~0.3 s for zon).
--   picker():       fzf-lua list of modified/added/removed files with a diff preview.
--   remote(dir):    `cvs -n -q update` (network): also shows files changed on the server
--                   (U/P = you need cvs update, C = conflict, ? = not in CVS). Results -> quickfix.
local entries = require('zon.cvs.entries')
local run = require('zon.cvs.run')

local M = {}

M.meaning = {
    M = 'modified',
    A = 'added',
    R = 'removed',
    C = 'conflict',
    ['!'] = 'missing',
    ['?'] = 'not in CVS',
    U = 'changed on server (needs update)',
    P = 'changed on server (needs update)',
}

-- cb({ { status, path (relative to root), abs } ... })
function M.scan(root, cb)
    local script = vim.fn.stdpath('config') .. '/lua/zon/cvs/scan_job.lua'
    vim.system(
        { vim.v.progpath, '--clean', '-l', script, root },
        { text = true },
        vim.schedule_wrap(function(res)
            if res.code ~= 0 then
                return vim.notify('CVS scan failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
            end
            local items = {}
            for st, abs in (res.stdout or ''):gmatch('(%S)\t([^\n]+)') do
                table.insert(
                    items,
                    { status = st, abs = abs, path = vim.fs.relpath(root, abs) or abs }
                )
            end
            cb(items)
        end)
    )
end

function M.picker()
    local root = require('zon.root').zon_root()
    if not root then return vim.notify('Not in a zon checkout', vim.log.levels.WARN) end
    M.scan(root, function(items)
        if #items == 0 then return vim.notify('CVS: no local changes') end
        local fzf = require('fzf-lua')
        local color = { M = 'yellow', A = 'green', R = 'red', C = 'magenta', ['!'] = 'red' }
        local lines = {}
        for _, it in ipairs(items) do
            local c = fzf.utils.ansi_codes[color[it.status] or 'blue']
            table.insert(lines, c(it.status) .. ' ' .. it.path)
        end
        local function path_of(sel) return root .. '/' .. fzf.utils.strip_ansi_coloring(sel):sub(3) end
        fzf.fzf_exec(lines, {
            prompt = 'CVS modified> ',
            cwd = root,
            fzf_opts = { ['--ansi'] = true, ['--multi'] = true },
            preview = {
                type = 'cmd',
                fn = function(sel)
                    local p = path_of(sel[1])
                    return ('cd %s && cvs -f -Q diff -N -u %s'):format(
                        vim.fn.shellescape(vim.fs.dirname(p)),
                        vim.fn.shellescape(vim.fs.basename(p))
                    )
                end,
            },
            actions = {
                ['enter'] = function(sel)
                    for _, s in ipairs(sel) do
                        vim.cmd.edit(vim.fn.fnameescape(path_of(s)))
                    end
                end,
                ['ctrl-v'] = function(sel) vim.cmd.vsplit(vim.fn.fnameescape(path_of(sel[1]))) end,
                ['ctrl-d'] = function(sel) require('zon.cvs.diff').open(path_of(sel[1]), 'BASE') end,
                ['ctrl-q'] = function(sel)
                    local qf = {}
                    for _, s in ipairs(sel) do
                        local st = fzf.utils.strip_ansi_coloring(s):sub(1, 1)
                        table.insert(
                            qf,
                            {
                                filename = path_of(s),
                                lnum = 1,
                                text = st .. ' ' .. (M.meaning[st] or ''),
                            }
                        )
                    end
                    vim.fn.setqflist({}, ' ', { title = 'CVS modified', items = qf })
                    vim.cmd('botright copen')
                end,
            },
        })
    end)
end

function M.remote(dir)
    dir = dir or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    if dir == '' or dir == '.' then dir = vim.uv.cwd() end
    vim.notify('cvs -n update in ' .. dir .. ' ...')
    run.run({ '-n', '-q', 'update' }, { cwd = dir }, function(_, out, err)
        local qf = {}
        for line in (out .. '\n' .. err):gmatch('[^\n]+') do
            local st, path = line:match('^(%S) (.+)$')
            if st and M.meaning[st] then
                table.insert(
                    qf,
                    { filename = dir .. '/' .. path, lnum = 1, text = st .. ' ' .. M.meaning[st] }
                )
            end
        end
        vim.fn.setqflist({}, ' ', { title = 'cvs -n update ' .. dir, items = qf })
        if #qf == 0 then
            vim.notify('CVS: up to date, no changes in ' .. dir)
        else
            vim.cmd('botright copen')
        end
    end)
end

return M
