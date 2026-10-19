-- leap: jump anywhere on screen. s{c1}{c2} then the label.
--   s   jump (both directions, current window)    S  jump to other windows
--   gs  remote action ("visit"): gs{target} then an operator, cursor returns
--   z   in operator-pending mode: dz{c1}{c2}{label} (ds/cs/ys belong to nvim-surround)
require('helpers.pack').add({ 'https://codeberg.org/andyg/leap.nvim' })

local map = require('helpers.map').map

map({ 'n', 'x', 'o' }, 's', '<Plug>(leap)', 'Leap')
map('n', 'S', '<Plug>(leap-from-window)', 'Leap to other windows')
map('o', 'z', '<Plug>(leap)', 'Leap (operator-pending)')
map({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-visit)', 'Leap visit (remote operation)')
