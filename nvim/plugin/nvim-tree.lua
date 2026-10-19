-- nvim-tree: file tree sidebar. In the tree: g? help, a add, d delete, r rename,
-- x/c/p cut/copy/paste, <C-v> vsplit, H toggle dotfiles, I toggle ignored, - up.
require('helpers.pack').add({ 'nvim-tree/nvim-web-devicons', 'nvim-tree/nvim-tree.lua' })

local nmap = require('helpers.map').nmap

require('nvim-tree').setup({
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = { enable = true, update_root = { enable = false } },
    view = { width = 35 },
    renderer = {
        root_folder_label = ':~:s?$?/..?',
        group_empty = true,
        icons = { git_placement = 'signcolumn', diagnostics_placement = 'after' },
    },
    git = { enable = true, show_on_dirs = true, show_on_open_dirs = false, timeout = 1000 },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = false,
        severity = { min = vim.diagnostic.severity.WARN },
    },
    filters = { custom = { '^\\.git$', '^CVS$' } },
})

nmap('<leader>tt', '<cmd>NvimTreeToggle<CR>', 'Toggle file tree')
nmap('<leader>e', '<cmd>NvimTreeFindFile<CR>', 'Show current file in tree')
