-- zmocha runner (see doc/skills/zmocha/SKILL.md).
-- zmocha maps the source dir to build.<BUILD>/pkg/..., so we run it from the
-- test file's directory with BUILD set:  cd <dir> && BUILD=<b> zmocha -T <file> [-f <test>]
local M = {}

local last

local function is_test(path)
    return path:match('%.test%.js$') or path:match('/test%.js$') or path:match('/test_[^/]+%.js$')
end

-- Find the test file for a source file (or return the file itself if it is a test).
function M.test_file(path)
    if is_test(path) then return path end
    local dir, name = vim.fs.dirname(path), vim.fs.basename(path):gsub('%.js$', '')
    for _, c in ipairs({
        dir .. '/' .. name .. '.test.js',
        dir .. '/tests/' .. name .. '.test.js',
        dir .. '/test/' .. name .. '.js',
        dir .. '/test.js',
    }) do
        if vim.uv.fs_stat(c) then return c end
    end
end

-- :A - alternate between a source file and its test.
function M.alternate()
    local path = vim.api.nvim_buf_get_name(0)
    local target
    if is_test(path) then
        local dir, base = vim.fs.dirname(path), vim.fs.basename(path)
        local name = base:gsub('%.test%.js$', ''):gsub('%.js$', '')
        for _, c in ipairs({
            dir .. '/' .. name .. '.js',
            vim.fs.dirname(dir) .. '/' .. name .. '.js',
        }) do
            if c ~= path and vim.uv.fs_stat(c) then
                target = c
                break
            end
        end
    else
        target = M.test_file(path)
    end
    if not target then return vim.notify('No alternate file found', vim.log.levels.WARN) end
    vim.cmd.edit(vim.fn.fnameescape(target))
end

-- Title of the closest it(...) / describe(...) above the cursor.
local function test_at_cursor()
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, lnum, false)
    for i = #lines, 1, -1 do
        local l = lines[i]
        local title = l:match('^%s*it[%.%w]*%(%s*[\'"`](.-)[\'"`]')
            or l:match('^%s*describe[%.%w]*%(%s*[\'"`](.-)[\'"`]')
            or l:match('^%s*zdescribe%b()%(%s*[\'"`](.-)[\'"`]')
        if title then return title end
    end
end

local function run(spec)
    local root = require('zon.root').zon_root(spec.file)
    if not root then return vim.notify('Not in a zon checkout', vim.log.levels.WARN) end
    local build = require('zon.build').get(root)
    if not build then
        return vim.notify('No configured build.<name>/ found (run jmake cc)', vim.log.levels.ERROR)
    end
    local cmd = { 'zmocha', '-T', vim.fs.basename(spec.file) }
    if spec.filter then vim.list_extend(cmd, { '-f', spec.filter }) end
    last = spec
    Snacks.terminal.open(cmd, {
        cwd = vim.fs.dirname(spec.file),
        env = { BUILD = build },
        interactive = false,
        win = { position = 'bottom', height = 0.4, enter = false },
    })
end

function M.file()
    if vim.bo.modified then vim.cmd('write') end
    local file = M.test_file(vim.api.nvim_buf_get_name(0))
    if not file then return vim.notify('No test file for this buffer', vim.log.levels.WARN) end
    run({ file = file })
end

function M.nearest()
    if vim.bo.modified then vim.cmd('write') end
    local file = vim.api.nvim_buf_get_name(0)
    if not is_test(file) then return vim.notify('Not a test file', vim.log.levels.WARN) end
    run({ file = file, filter = test_at_cursor() })
end

function M.last()
    if not last then return vim.notify('No previous zmocha run', vim.log.levels.WARN) end
    vim.cmd('silent! wall')
    run(last)
end

return M
