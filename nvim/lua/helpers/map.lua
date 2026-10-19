-- Keymap helper.
-- map(mode, lhs, rhs, desc, opts) works like vim.keymap.set(), but:
--   * desc is required (which-key shows it, fzf-lua keymaps can search it);
--   * silent = true by default;
--   * every mapping is recorded in M.registry with the file:line that defined it.
--     :Cheatsheet uses the registry to generate a markdown cheatsheet.
local M = {}

M.registry = {}
local seen = {}

local function location()
    for level = 3, 8 do
        local info = debug.getinfo(level, 'Sl')
        if not info then break end
        local src = info.source:match('^@?.*/nvim/(.+)$') or info.source
        if
            info.currentline > 0
            and not src:match('helpers/map%.lua$')
            and not src:match('helpers/func%.lua$')
        then
            return src .. ':' .. info.currentline
        end
    end
    return '?'
end

function M.map(mode, lhs, rhs, desc, opts)
    opts = vim.tbl_extend('force', { silent = true }, opts or {})
    opts.desc = desc
    vim.keymap.set(mode, lhs, rhs, opts)
    local modes = type(mode) == 'table' and table.concat(mode) or mode
    local key = modes .. '\0' .. lhs .. '\0' .. desc
    if not seen[key] then
        seen[key] = true
        table.insert(M.registry, {
            mode = modes,
            lhs = lhs,
            desc = desc,
            where = location(),
            buffer = opts.buffer ~= nil,
        })
    end
end

local partial = require('helpers.func').partial
M.nmap = partial(M.map, 'n')
M.vmap = partial(M.map, 'v')
M.xmap = partial(M.map, 'x')
M.imap = partial(M.map, 'i')
M.cmap = partial(M.map, 'c')
M.omap = partial(M.map, 'o')
M.tmap = partial(M.map, 't')
M.nxmap = partial(M.map, { 'n', 'x' })

return M
