-- blink.cmp: completion (LSP, paths, snippets, buffer words, cmdline).
--   <CR> accept   <C-n>/<C-p> or <Up>/<Down> select   <C-Space> open / docs   <C-e> close
--   <Tab>/<S-Tab> jump between snippet placeholders   <C-k> signature help
-- Snippets: friendly-snippets + ~/.config/nvim/snippets/*.json (zon snippets).
require('helpers.pack').add({
    { src = 'saghen/blink.cmp', version = vim.version.range('1') },
    'rafamadriz/friendly-snippets',
})

require('blink.cmp').setup({
    keymap = { preset = 'enter' },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        list = { selection = { preselect = true, auto_insert = false } },
        menu = { draw = { treesitter = { 'lsp' } } },
        accept = { auto_brackets = { enabled = true } },
    },
    signature = { enabled = true },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
            lua = { inherit_defaults = true, 'lazydev' },
        },
        providers = {
            lazydev = {
                name = 'LazyDev',
                module = 'lazydev.integrations.blink',
                score_offset = 100,
            },
        },
    },
    cmdline = {
        keymap = { preset = 'cmdline' },
        completion = {
            menu = {
                auto_show = function() return vim.fn.getcmdtype() == ':' end,
            },
            list = { selection = { preselect = false } },
        },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
})
