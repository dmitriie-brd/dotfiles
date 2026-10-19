-- quicker.nvim: better quickfix window.
--   Edit lines in the quickfix list and :w applies the changes to the files (mass edit after grep).
--   > / < in the quickfix window: show / hide context lines around each item.
require('helpers.pack').add({ 'stevearc/quicker.nvim' })

local quicker = require('quicker')
local nmap = require('helpers.map').nmap

quicker.setup({
    keys = {
        {
            '>',
            function() quicker.expand({ before = 2, after = 2, add_to_existing = true }) end,
            desc = 'Expand quickfix context',
        },
        {
            '<',
            function() quicker.collapse() end,
            desc = 'Collapse quickfix context',
        },
    },
})

nmap('<leader>tq', function() quicker.toggle() end, 'Toggle quickfix')
nmap('<leader>tL', function() quicker.toggle({ loclist = true }) end, 'Toggle location list')
