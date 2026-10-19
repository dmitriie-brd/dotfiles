-- File content at a revision: `cvs update -p -r REV file`, cached on disk.
-- A numbered revision never changes, so the cache never expires
-- (~/.cache/nvim/cvs/<repository>/<file>@<rev>). HEAD is never cached.
local run = require('zon.cvs.run')

local M = {}

M.dir = vim.fn.stdpath('cache') .. '/cvs'

local pending = {} -- key -> callbacks

local function key_path(info, rev)
    return M.dir .. '/' .. info.repo .. '/' .. info.name .. '@' .. rev
end

local function read_lines(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local s = f:read('*a')
    f:close()
    return run.lines(s)
end

-- cb(lines | nil, err)
function M.get(info, rev, cb)
    if rev == '0' then return cb({}) end
    local cacheable = rev:match('^[%d%.]+$') ~= nil
    local path = key_path(info, rev)
    if cacheable then
        local lines = read_lines(path)
        if lines then return cb(lines) end
    end
    if pending[path] then return table.insert(pending[path], cb) end
    pending[path] = { cb }
    run.run(
        { '-Q', 'update', '-p', '-r', rev, info.name },
        { cwd = info.dir },
        function(ok, out, err)
            local cbs = pending[path]
            pending[path] = nil
            if not ok then
                for _, f in ipairs(cbs) do
                    f(nil, vim.trim(err))
                end
                return
            end
            if cacheable then
                vim.fn.mkdir(vim.fs.dirname(path), 'p')
                local f = io.open(path, 'w')
                if f then
                    f:write(out)
                    f:close()
                end
            end
            local lines = run.lines(out)
            for _, f in ipairs(cbs) do
                f(lines)
            end
        end
    )
end

return M
