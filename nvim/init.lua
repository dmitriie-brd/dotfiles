-- Entry point. Load order:
--   1. this file: leader + lua/core/* (options, keymaps, autocmds, filetypes)
--   2. plugin/*.lua (alphabetical; "+" sorts first, "~" sorts last).
--      Each file installs its plugins with vim.pack.add() and configures them.
--   3. after/ftplugin/*.lua per filetype.

vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.filetypes')
