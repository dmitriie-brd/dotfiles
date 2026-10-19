-- Project roots.
--   zon_root(buf_or_path): the zon checkout root (dir with pkg/ and CVS/Repository == "zon"), or nil.
--   get(buf):              zon root, else .git / Cargo.toml / package.json root, else cwd.
local M = {}

local cache = {}

local function read_first_line(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local l = f:read('*l')
    f:close()
    return l
end

local function is_zon_root(dir)
    if cache[dir] ~= nil then return cache[dir] end
    local repo = read_first_line(dir .. '/CVS/Repository')
    local ok = repo ~= nil and vim.trim(repo) == 'zon' and vim.fn.isdirectory(dir .. '/pkg') == 1
    cache[dir] = ok
    return ok
end

local function to_dir(src)
    local path
    if src == nil or type(src) == 'number' then
        path = vim.api.nvim_buf_get_name(src or 0)
    else
        path = src
    end
    if path == '' or path:match('^%w%w+://') then return vim.uv.cwd() end
    path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
    if vim.fn.isdirectory(path) == 1 then return path end
    return vim.fs.dirname(path)
end

function M.zon_root(src)
    local dir = to_dir(src)
    if is_zon_root(dir) then return dir end
    for parent in vim.fs.parents(dir) do
        if is_zon_root(parent) then return parent end
    end
    return nil
end

function M.get(src)
    local z = M.zon_root(src)
    if z then return z end
    local dir = to_dir(src)
    -- vim.fs.root() starts at the parent of a file path; pass a dummy file inside dir.
    return vim.fs.root(dir .. '/_', { '.git', 'Cargo.toml', 'package.json' }) or vim.uv.cwd()
end

return M
