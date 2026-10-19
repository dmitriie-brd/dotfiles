-- goto-preview: show definition/type/implementation in a float, stay where you are.
-- In the float you can edit; <C-w>q or <leader>cP closes all previews. Loaded on first use.
local pack = require('helpers.pack')
pack.add({ 'rmagatti/goto-preview' }, { lazy = true })

local nmap = require('helpers.map').nmap
local load = pack.lazy_setup(
    'goto-preview',
    function()
        require('goto-preview').setup({
            default_mappings = false,
            preview_window_title = { enable = true, position = 'right' },
        })
    end
)
local function gp(fn)
    return function()
        load()
        require('goto-preview')[fn]()
    end
end

nmap('<leader>cp', gp('goto_preview_definition'), 'Peek definition')
nmap('<leader>ct', gp('goto_preview_type_definition'), 'Peek type definition')
nmap('<leader>ci', gp('goto_preview_implementation'), 'Peek implementation')
nmap('<leader>cP', gp('close_all_win'), 'Close all peek windows')
