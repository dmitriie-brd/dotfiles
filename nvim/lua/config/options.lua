-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.root_spec = {"cwd"}
vim.g.autoformat = false
vim.g.snacks_animate = false

local opt = vim.opt
opt.clipboard = "unnamedplus"
opt.smarttab = false -- see neovim/neovim#15925
opt.tabstop = 4 -- A TAB character looks like 4 spaces
opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
opt.shiftwidth = 4 -- Number of spaces inserted when indenting
opt.colorcolumn = "80"
