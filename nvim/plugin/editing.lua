-- Editing helpers.
--   nvim-surround: ys{motion}{char} add, cs{old}{new} change, ds{char} delete, S{char} in visual.
--                  Examples: ysiw' -> 'word'   cs'" -> "word"   dst -> remove tag   ysa)f -> f(...)
--   mini.pairs:    auto-close brackets and quotes.
--   guess-indent:  detect indent per file (4 spaces in zon JS, 2 in JSX, tabs in Makefile).
--   todo-comments: highlight TODO/FIXME/XXX (also zon "// XXX login: reason"); ]t [t jump.
--   grug-far:      project-wide search and replace with preview (ripgrep).
--   persistence:   sessions per directory.
local pack = require('helpers.pack')
pack.add({
    { src = 'kylechui/nvim-surround', version = vim.version.range('4') },
    'nvim-mini/mini.pairs',
    'NMAC427/guess-indent.nvim',
    'nvim-lua/plenary.nvim',
    'folke/todo-comments.nvim',
    'folke/persistence.nvim',
})
pack.add({ 'MagicDuck/grug-far.nvim' }, { lazy = true })

local m = require('helpers.map')

require('nvim-surround').setup({})
vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function()
        require('mini.pairs').setup({ modes = { insert = true, command = false, terminal = false } })
    end,
})
require('guess-indent').setup({})

----------------------------------------
-- TODO comments
----------------------------------------
-- Deferred: ~10 ms of setup, not needed for the first screen.
vim.schedule(
    function()
        require('todo-comments').setup({
            signs = false,
            highlight = { pattern = [[.*<(KEYWORDS)(\s+\w+)?\s*:]] },
            search = { pattern = [[\b(KEYWORDS)(\s+\w+)?:]] },
        })
    end
)
m.nmap(']t', function() require('todo-comments').jump_next() end, 'Next TODO/XXX comment')
m.nmap('[t', function() require('todo-comments').jump_prev() end, 'Previous TODO/XXX comment')
m.nmap(
    '<leader>st',
    function() require('todo-comments.fzf').todo({ cwd = vim.fn.expand('%:p:h') }) end,
    "TODO/XXX comments (current file's dir)"
)

----------------------------------------
-- Search and replace
----------------------------------------
local load_grug = pack.lazy_setup(
    'grug-far.nvim',
    function() require('grug-far').setup({ headerMaxWidth = 80 }) end
)
local function grug()
    load_grug()
    return require('grug-far')
end
m.nmap(
    '<leader>sr',
    function()
        grug().open({
            prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%:p:h') },
        })
    end,
    'Search and replace (word, current dir)'
)
m.xmap(
    '<leader>sr',
    function() grug().with_visual_selection({ prefills = { paths = vim.fn.expand('%:p:h') } }) end,
    'Search and replace (selection)'
)
m.nmap(
    '<leader>sf',
    function() grug().open({ prefills = { paths = vim.fn.expand('%') } }) end,
    'Search and replace (current file)'
)

----------------------------------------
-- Sessions
----------------------------------------
local persistence = require('persistence')
persistence.setup({})
m.nmap('<leader>qs', persistence.load, 'Restore session (this dir)')
m.nmap('<leader>qS', persistence.select, 'Select session')
m.nmap('<leader>ql', function() persistence.load({ last = true }) end, 'Restore last session')
m.nmap('<leader>qd', persistence.stop, "Don't save this session")
