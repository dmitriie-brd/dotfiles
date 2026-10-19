-- bufferline: the top line shows open buffers (files) like tabs, as in LazyVim.
-- Real tab pages (cheatsheet, CVS diffs) appear as numbers at the right end; gt / gT move between them.
--   <S-h> / <S-l>   previous / next buffer (replaces built-in H / L = screen top / bottom)
--   <leader>bj      pick a buffer by letter          <leader>bp  pin / unpin
--   <leader>bP      close all unpinned buffers       <leader>bl / <leader>br  close buffers to the left / right
--   <leader>b[ / <leader>b]   move the buffer left / right in the line
--   <leader>bd      close this buffer   <leader>bo  close all other buffers   (plugin/+snacks.lua)
require('helpers.pack').add({
    'nvim-tree/nvim-web-devicons',
    { src = 'akinsho/bufferline.nvim', version = vim.version.range('4') },
})

local m = require('helpers.map')

require('bufferline').setup({
    options = {
        mode = 'buffers',
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(_, _, diag)
            local s = {}
            if diag.error then table.insert(s, '\u{f057} ' .. diag.error) end
            if diag.warning then table.insert(s, '\u{f071} ' .. diag.warning) end
            return table.concat(s, ' ')
        end,
        always_show_bufferline = true,
        show_tab_indicators = true,
        offsets = {
            { filetype = 'NvimTree', text = 'Files', highlight = 'Directory', text_align = 'left' },
        },
    },
})

m.nmap('<S-h>', '<cmd>BufferLineCyclePrev<CR>', 'Previous buffer')
m.nmap('<S-l>', '<cmd>BufferLineCycleNext<CR>', 'Next buffer')
m.nmap('<leader>bj', '<cmd>BufferLinePick<CR>', 'Pick buffer')
m.nmap('<leader>bp', '<cmd>BufferLineTogglePin<CR>', 'Pin / unpin buffer')
m.nmap('<leader>bP', '<cmd>BufferLineGroupClose ungrouped<CR>', 'Close unpinned buffers')
m.nmap('<leader>bl', '<cmd>BufferLineCloseLeft<CR>', 'Close buffers to the left')
m.nmap('<leader>br', '<cmd>BufferLineCloseRight<CR>', 'Close buffers to the right')
m.nmap('<leader>b[', '<cmd>BufferLineMovePrev<CR>', 'Move buffer left')
m.nmap('<leader>b]', '<cmd>BufferLineMoveNext<CR>', 'Move buffer right')
