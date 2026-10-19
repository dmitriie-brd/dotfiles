-- Standalone job: nvim --clean -l scan_job.lua <root>
-- Prints "<status>\t<abs path>" for every locally changed CVS file under root.
-- Runs in a separate process so the editor never blocks (zon has ~4700 CVS dirs).
local root = assert(arg[1], 'usage: scan_job.lua <root>')
local here = debug.getinfo(1, 'S').source:sub(2):match('^(.*)/zon/cvs/scan_job%.lua$')
package.path = here .. '/?.lua;' .. package.path

local entries = require('zon.cvs.entries')

local res = vim.system({
    'fd',
    '--hidden',
    '--no-ignore',
    '--type',
    'd',
    '--glob',
    'CVS',
    '--exclude',
    'build.*',
    '--exclude',
    'node_modules',
    '--exclude',
    'target',
    '--absolute-path',
    '--search-path',
    root,
}, { text = true }):wait()

local out = {}
for cvsdir in (res.stdout or ''):gmatch('[^\n]+') do
    local dir = vim.fs.dirname((cvsdir:gsub('/$', '')))
    local d = entries.dir(dir)
    if d then
        for name, e in pairs(d.entries) do
            local st = entries.status(dir, e)
            if st then table.insert(out, st .. '\t' .. dir .. '/' .. name) end
        end
    end
end
table.sort(out)
io.stdout:write(table.concat(out, '\n'))
