-- zon BUILD selection. zmocha needs BUILD=<name> and an existing build.<name>/ tree.
--   get(root):  vim.g.zon_build if valid, else $BUILD if valid, else the most recently
--               configured build.<name>/ (newest pkg/zon_config_int.json).
--   :ZonBuild [name]  switch (no argument: pick from a list).
local M = {}

function M.list(root)
    local res = {}
    for _, cfg in ipairs(vim.fn.glob(root .. '/build.*/pkg/zon_config_int.json', true, true)) do
        local name = cfg:match('/build%.([^/]+)/pkg/zon_config_int%.json$')
        local st = vim.uv.fs_stat(cfg)
        table.insert(res, { name = name, mtime = st and st.mtime.sec or 0 })
    end
    table.sort(res, function(a, b) return a.mtime > b.mtime end)
    return res
end

local function valid(root, name)
    return name
        and name ~= ''
        and vim.uv.fs_stat(root .. '/build.' .. name .. '/pkg/zon_config_int.json') ~= nil
end

function M.get(root)
    root = root or require('zon.root').zon_root()
    if not root then return nil end
    if valid(root, vim.g.zon_build) then return vim.g.zon_build end
    if valid(root, vim.env.BUILD) then return vim.env.BUILD end
    local l = M.list(root)
    return l[1] and l[1].name
end

function M.select(name)
    local root = require('zon.root').zon_root()
    if not root then return vim.notify('Not in a zon checkout', vim.log.levels.WARN) end
    if name and name ~= '' then
        if not valid(root, name) then
            return vim.notify('No configured build.' .. name, vim.log.levels.ERROR)
        end
        vim.g.zon_build = name
        return vim.notify('BUILD=' .. name)
    end
    local names = vim.tbl_map(function(b) return b.name end, M.list(root))
    vim.ui.select(names, { prompt = 'zon BUILD' }, function(choice)
        if choice then
            vim.g.zon_build = choice
            vim.notify('BUILD=' .. choice)
        end
    end)
end

return M
