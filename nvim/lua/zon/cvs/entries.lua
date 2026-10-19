-- Read CVS/Entries (local, no network).
-- Entry line format: /name/revision/timestamp/options/tagdate
--   revision "0" = added, "-1.5" = removed; timestamp is the file mtime (UTC) at checkout.
local M = {}

local cache = {} -- dir -> { mtime, entries, repo }

local function read(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local s = f:read('*a')
    f:close()
    return s
end

function M.dir(dir)
    local efile = dir .. '/CVS/Entries'
    local st = vim.uv.fs_stat(efile)
    if not st then return nil end
    local c = cache[dir]
    if c and c.mtime == st.mtime.sec and c.nsec == st.mtime.nsec then return c end
    local entries = {}
    for line in (read(efile) or ''):gmatch('[^\n]+') do
        local name, rev, ts, opts, tag = line:match('^/([^/]*)/([^/]*)/([^/]*)/([^/]*)/(.*)$')
        if name then entries[name] = { name = name, rev = rev, ts = ts, opts = opts, tag = tag } end
    end
    local repo = vim.trim(read(dir .. '/CVS/Repository') or '')
    c = { mtime = st.mtime.sec, nsec = st.mtime.nsec, entries = entries, repo = repo }
    cache[dir] = c
    return c
end

-- Info for a file path: { path, dir, name, rev, ts, repo } or nil if not CVS-managed.
function M.info(path)
    if not path or path == '' or path:match('^%w%w+://') then return nil end
    path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
    local dir, name = vim.fs.dirname(path), vim.fs.basename(path)
    local d = M.dir(dir)
    if not d then return nil end
    local e = d.entries[name]
    return {
        path = path,
        dir = dir,
        name = name,
        repo = d.repo,
        rev = e and e.rev or nil, -- nil = unknown file in a CVS dir
        ts = e and e.ts or nil,
    }
end

-- Local status letter (like `cvs -n update`, but offline):
--   nil clean, M modified, A added, R removed, C conflict, ! missing, ? unknown
function M.status(dir, e)
    if not e then return '?' end
    if e.rev == '0' then return 'A' end
    if e.rev:sub(1, 1) == '-' then return 'R' end
    local st = vim.uv.fs_stat(dir .. '/' .. e.name)
    if not st then return '!' end
    if e.ts:find('+', 1, true) then return 'C' end
    if e.ts:match('^Result of merge') or e.ts:match('^dummy') then return 'M' end
    local ts = os.date('!%a %b %e %H:%M:%S %Y', st.mtime.sec)
    if ts ~= e.ts and os.date('!%a %b %d %H:%M:%S %Y', st.mtime.sec) ~= e.ts then return 'M' end
    return nil
end

return M
