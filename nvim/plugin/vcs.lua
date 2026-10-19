-- Version control: change signs for git AND CVS (mini.diff), full git review (diffview).
--   mini.diff (both VCS): ]h [h next/prev hunk, ]H [H last/first,
--     gh{motion} apply hunk (git: stage; CVS: not supported), gH{motion} reset hunk (undo the change),
--     ghgh / gHgh = apply/reset hunk under cursor, gh as text object (dgh, ygh),
--     <leader>go toggle overlay (inline diff in the buffer).
--   diffview (git only, loaded on first use): <leader>gd review changes, <leader>gh file history,
--     <leader>gl line history, <leader>gq close.
local pack = require('helpers.pack')
pack.add({ 'nvim-mini/mini.diff', 'nvim-tree/nvim-web-devicons' })
pack.add({ 'dlyongemallo/diffview.nvim' }, { lazy = true })

local m = require('helpers.map')
local diff = require('mini.diff')

diff.setup({
    view = { style = 'sign', signs = { add = '▎', change = '▎', delete = '\u{2581}' } },
    source = { diff.gen_source.git(), require('zon.cvs.minidiff').source() },
})

m.nmap('<leader>go', function() diff.toggle_overlay(0) end, 'Toggle diff overlay (git/CVS)')

----------------------------------------
-- diffview (git)
----------------------------------------
local load = pack.lazy_setup(
    'diffview.nvim',
    function() require('diffview').setup({ enhanced_diff_hl = true }) end
)
local function dv(cmd)
    return function()
        load()
        vim.cmd(cmd)
    end
end

m.nmap('<leader>gd', dv('DiffviewOpen'), 'Diffview: working tree vs HEAD')
m.nmap('<leader>gq', dv('DiffviewClose'), 'Diffview: close')
m.nmap('<leader>gh', dv('DiffviewFileHistory --follow %'), 'Diffview: file history')
m.nmap('<leader>gH', dv('DiffviewFileHistory'), 'Diffview: repo history')
m.nmap('<leader>gl', dv('.DiffviewFileHistory --follow'), 'Diffview: line history')
m.xmap('<leader>gl', function()
    load()
    vim.cmd("'<,'>DiffviewFileHistory --follow")
end, 'Diffview: selection history')
vim.api.nvim_create_user_command('DiffviewOpen', function(o)
    vim.api.nvim_del_user_command('DiffviewOpen')
    load()
    vim.cmd('DiffviewOpen ' .. o.args)
end, { nargs = '*', desc = 'Diffview (loads the plugin)' })
