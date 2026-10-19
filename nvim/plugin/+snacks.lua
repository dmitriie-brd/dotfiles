-- snacks.nvim: a set of small modules. Only the ones listed here are enabled.
require('helpers.pack').add({ 'folke/snacks.nvim' })

local nmap = require('helpers.map').nmap
local map = require('helpers.map').map

require('snacks').setup({
    -- Huge files (mongo_slow.log, minified bundles): no treesitter/LSP/syntax.
    bigfile = { enabled = true, size = 1.5 * 1024 * 1024, line_length = 1000 },
    -- Notification popups + history (replaces noice).
    notifier = { enabled = true, timeout = 3000 },
    -- Nicer vim.ui.input (LSP rename, etc.).
    input = { enabled = true },
    -- Highlight other uses of the word under the cursor (LSP); ]] [[ jump.
    words = { enabled = true },
    -- Indent guides + current scope line.
    indent = { enabled = true, animate = { enabled = false } },
    scope = { enabled = true },
    terminal = { win = { position = 'bottom', height = 0.35 } },
    lazygit = {},
    styles = {
        notification = { wo = { wrap = true } },
    },
})

nmap('<leader>sn', function() Snacks.notifier.show_history() end, 'Notification history')
nmap('<leader>un', function() Snacks.notifier.hide() end, 'Dismiss notifications')

map(
    { 'n', 't' },
    '<C-/>',
    function() Snacks.terminal.toggle(nil, { cwd = require('zon.root').get() }) end,
    'Toggle terminal (project root)'
)
map(
    { 'n', 't' },
    '<C-_>',
    function() Snacks.terminal.toggle(nil, { cwd = require('zon.root').get() }) end,
    'Toggle terminal (project root)'
)

nmap(']]', function() Snacks.words.jump(vim.v.count1) end, 'Next reference of word')
nmap('[[', function() Snacks.words.jump(-vim.v.count1) end, 'Previous reference of word')

nmap('<leader>bd', function() Snacks.bufdelete() end, 'Delete buffer (keep window)')
nmap('<leader>bo', function() Snacks.bufdelete.other() end, 'Delete other buffers')
nmap(
    '<leader>cR',
    function() Snacks.rename.rename_file() end,
    'Rename file (updates imports via LSP)'
)

nmap(
    '<leader>gg',
    function() Snacks.lazygit({ cwd = require('zon.root').get() }) end,
    'Lazygit (git repos)'
)
nmap('<leader>gb', function() Snacks.git.blame_line() end, 'Git blame line')
