-- zlint integration.
--   Live diagnostics: nvim-lint runs `zlint -c <file>` on open and on save (see plugin/lint.lua).
--   Quickfix:         run(files, args) -> async zlint, results in the quickfix list.
--   Autofix:          the conform formatter "zlint_fix" (see plugin/format.lua).
--
-- Note: `zlint -a` is broken on this machine (~/.eslintrc-nohola.js requires a
-- missing ./eslintrc.js), so autofix calls eslint directly with the checkout's
-- pkg/system/host/eslintrc-nohola.js. This is the same command zlint -a runs.
local M = {}

M.efm = '%f:%l:%c: [%tRROR]%m,%f:%l:%c: [%tARN]%m,%-G%f: OK,%-G%.%#'

-- nvim-lint linter definition.
function M.linter()
    return {
        name = 'zlint',
        cmd = 'zlint',
        args = { '-c' },
        stdin = false,
        append_fname = true,
        stream = 'stdout',
        ignore_exitcode = true,
        parser = require('lint.parser').from_pattern(
            '^.-:(%d+):(%d+): %[(%u+)%]%[([^%]]*)%] (.*)$',
            { 'lnum', 'col', 'severity', 'code', 'message' },
            { ERROR = vim.diagnostic.severity.ERROR, WARN = vim.diagnostic.severity.WARN },
            { source = 'zlint' }
        ),
    }
end

-- Arguments for `eslint --fix` (used by the conform formatter).
function M.fix_args(root)
    return {
        '--fix',
        '--no-eslintrc',
        '--no-ignore', -- conform writes a temp .conform.*.js (dotfiles are ignored by default)
        '-c',
        root .. '/pkg/system/host/eslintrc-nohola.js',
        '--parser-options',
        'ecmaVersion:2022,ecmaFeatures:{jsx:true}',
        '-f',
        'unix',
        '$FILENAME',
    }
end

-- Run zlint on files, put findings in the quickfix list.
function M.run(files, args, title)
    if #files == 0 then return vim.notify('zlint: no files', vim.log.levels.WARN) end
    local cmd = vim.list_extend({ 'zlint' }, args or {})
    vim.list_extend(cmd, files)
    title = title or table.concat(cmd, ' ')
    vim.notify('zlint: running on ' .. #files .. ' file(s)...')
    vim.system(
        cmd,
        { text = true, cwd = require('zon.root').get() },
        vim.schedule_wrap(function(res)
            local lines =
                vim.split((res.stdout or '') .. (res.stderr or ''), '\n', { trimempty = true })
            vim.fn.setqflist({}, ' ', { title = title, lines = lines, efm = M.efm })
            local n = #vim.fn.getqflist()
            if n == 0 then
                vim.notify('zlint: OK (' .. #files .. ' file(s))')
                vim.cmd('cclose')
            else
                vim.notify('zlint: ' .. n .. ' finding(s)', vim.log.levels.WARN)
                vim.cmd('botright copen')
            end
        end)
    )
end

function M.current(args)
    local file = vim.api.nvim_buf_get_name(0)
    if vim.bo.modified then vim.cmd('write') end
    M.run({ file }, args)
end

-- zlint -c on all CVS-modified JS files under the zon root.
function M.modified()
    local root = require('zon.root').zon_root()
    if not root then return vim.notify('Not in a zon checkout', vim.log.levels.WARN) end
    vim.cmd('silent! wall')
    require('zon.cvs.status').scan(root, function(items)
        local files = {}
        for _, it in ipairs(items) do
            if it.status ~= 'R' and it.status ~= '!' and it.path:match('%.[jt]sx?$') then
                table.insert(files, it.abs)
            end
        end
        M.run(files, { '-c' }, 'zlint -c (CVS modified)')
    end)
end

return M
