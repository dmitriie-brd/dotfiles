-- Color scheme: gruvbox-material. :ToggleBackground (or <leader>tb) switches dark/light.
require('helpers.pack').add({ 'sainnhe/gruvbox-material' })

vim.g.gruvbox_material_background = 'medium'
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_disable_italic_comment = 1
vim.g.gruvbox_material_float_style = 'blend'
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
vim.g.gruvbox_material_sign_column_background = 'none'

vim.o.background = 'dark'
vim.cmd.colorscheme('gruvbox-material')

local function toggle_background()
    vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
    vim.cmd.colorscheme('gruvbox-material')
end

vim.api.nvim_create_user_command(
    'ToggleBackground',
    toggle_background,
    { desc = 'Toggle dark/light' }
)
require('helpers.map').nmap('<leader>tb', toggle_background, 'Toggle background (dark/light)')
