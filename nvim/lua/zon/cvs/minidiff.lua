-- mini.diff source for CVS: reference text = the BASE revision (from CVS/Entries),
-- fetched once with `cvs update -p` and cached on disk. Signs then update instantly.
-- Re-fetches when the BASE revision changes (after `cvs update`).
local entries = require('zon.cvs.entries')
local cache = require('zon.cvs.cache')

local M = {}

local group = vim.api.nvim_create_augroup('MiniDiffCvs', { clear = true })

local function refresh(buf)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local info = entries.info(vim.api.nvim_buf_get_name(buf))
    if not info or not info.rev then return end
    if vim.b[buf].cvs_rev == info.rev then return end
    vim.b[buf].cvs_rev = info.rev
    cache.get(info, info.rev, function(lines)
        if lines and vim.api.nvim_buf_is_valid(buf) then
            require('mini.diff').set_ref_text(buf, lines)
        end
    end)
end

function M.source()
    return {
        name = 'cvs',
        attach = function(buf)
            local info = entries.info(vim.api.nvim_buf_get_name(buf))
            if not info or not info.rev then return false end
            vim.b[buf].cvs_rev = nil
            refresh(buf)
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'FocusGained', 'BufEnter' }, {
                group = group,
                buffer = buf,
                callback = function() refresh(buf) end,
            })
        end,
        detach = function(buf)
            pcall(vim.api.nvim_clear_autocmds, { group = group, buffer = buf })
            vim.b[buf].cvs_rev = nil
        end,
    }
end

return M
