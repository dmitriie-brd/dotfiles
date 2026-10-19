-- Async CVS runner. The CVS server is remote (:pserver:), so every call is a
-- network round trip (~1-1.5 s). Never block the UI: all calls are async, and at
-- most MAX run in parallel (opening many files queues the base-revision fetches).
local M = {}

local MAX = 4
local running = 0
local queue = {}

local function pump()
    while running < MAX and #queue > 0 do
        local job = table.remove(queue, 1)
        running = running + 1
        -- -f: ignore ~/.cvsrc (it adds -q, -dP, -u which change the output format).
        local cmd = vim.list_extend({ 'cvs', '-f' }, job.args)
        local ok, err = pcall(vim.system, cmd, { cwd = job.cwd, text = true }, function(res)
            running = running - 1
            vim.schedule(function()
                job.cb(res.code == 0, res.stdout or '', res.stderr or '')
                pump()
            end)
        end)
        if not ok then
            running = running - 1
            vim.schedule(function() job.cb(false, '', tostring(err)) end)
        end
    end
end

-- run({ 'annotate', 'file.js' }, { cwd = dir }, function(ok, stdout, stderr) end)
function M.run(args, opts, cb)
    table.insert(queue, { args = args, cwd = opts.cwd, cb = cb })
    pump()
end

-- Run several commands in parallel, call cb once with all results (same order).
function M.all(jobs, cb)
    local results, left = {}, #jobs
    for i, j in ipairs(jobs) do
        M.run(j.args, { cwd = j.cwd }, function(ok, out, err)
            results[i] = { ok = ok, out = out, err = err }
            left = left - 1
            if left == 0 then cb(results) end
        end)
    end
end

function M.lines(s)
    local l = vim.split(s, '\n', { plain = true })
    if l[#l] == '' then table.remove(l) end
    return l
end

return M
