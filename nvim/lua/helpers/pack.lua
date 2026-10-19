-- Thin wrapper around the native plugin manager (:h vim.pack).
-- Plugin versions are pinned in nvim-pack-lock.json (commit it).
-- Update: :lua vim.pack.update()   (review, then :w to apply, :q to cancel)
local M = {}

function M.gh(repo) return 'https://github.com/' .. repo end

-- Accepts 'owner/repo', a full URL, or a vim.pack.Spec table.
-- opts.lazy = true: install and add to 'runtimepath' only (require() works), but do not
-- source the plugin's plugin/ files. Use M.lazy_setup() to configure on first use.
function M.add(specs, opts)
    local list = {}
    for _, s in ipairs(specs) do
        if type(s) == 'string' and not s:match('^https?://') then
            s = M.gh(s)
        elseif type(s) == 'table' and not s.src:match('^https?://') then
            s = vim.tbl_extend('force', s, { src = M.gh(s.src) })
        end
        table.insert(list, s)
    end
    local o = { confirm = false }
    if opts and opts.lazy then o.load = false end
    vim.pack.add(list, o)
end

-- Returns a function that loads the plugin (packadd) and runs setup once.
function M.lazy_setup(name, setup)
    local done = false
    return function()
        if not done then
            done = true
            vim.cmd.packadd(name)
            if setup then setup() end
        end
    end
end

return M
