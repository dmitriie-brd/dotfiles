-- which-key: after <leader> (or g, z, [, ], ", ', <C-w>) pause and a popup shows the next keys.
-- Use <leader>? for buffer-local keymaps.
require('helpers.pack').add({ 'folke/which-key.nvim', 'nvim-tree/nvim-web-devicons' })

local wk = require('which-key')
wk.setup({
    preset = 'helix',
    delay = function(ctx) return ctx.plugin and 0 or 300 end,
    spec = {
        { '<leader>b', group = 'buffer' },
        { '<leader>c', group = 'code' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>h', group = 'help/learn' },
        { '<leader>q', group = 'quit/session' },
        { '<leader>r', group = 'rust' },
        { '<leader>s', group = 'search' },
        { '<leader>t', group = 'toggle' },
        { '<leader>u', group = 'ui' },
        { '<leader>w', group = 'window' },
        { '<leader>z', group = 'zon (CVS, zlint, zmocha)' },
        { 'gr', group = 'LSP' },
        { '[', group = 'prev' },
        { ']', group = 'next' },
        { 'g', group = 'goto' },
        { 'z', group = 'fold/scroll/spell' },
    },
})

require('helpers.map').nmap(
    '<leader>?',
    function() wk.show({ global = false }) end,
    'Buffer-local keymaps'
)
