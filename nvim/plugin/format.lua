-- Formatting (conform.nvim).
--   Format on save: only Rust (rustfmt) and Lua (stylua). Toggle: <leader>tf.
--   zon JS: never on save. <leader>cf (or <leader>zf) runs the zlint autofix (eslint --fix
--   with zon rules) on the buffer. Other JS projects: prettier if installed.
require('helpers.pack').add({ 'stevearc/conform.nvim' })

local conform = require('conform')
local m = require('helpers.map')

local function js_formatters(bufnr)
    if require('zon.root').zon_root(bufnr) then return { 'zlint_fix' } end
    return { 'prettierd', 'prettier', stop_after_first = true }
end

conform.setup({
    formatters_by_ft = {
        lua = { 'stylua' },
        rust = { 'rustfmt', lsp_format = 'fallback' },
        javascript = js_formatters,
        javascriptreact = js_formatters,
        typescript = js_formatters,
        typescriptreact = js_formatters,
        json = { lsp_format = 'prefer' },
    },
    formatters = {
        zlint_fix = {
            command = 'eslint',
            stdin = false,
            exit_codes = { 0, 1 },
            args = function(_, ctx)
                return require('zon.zlint').fix_args(require('zon.root').zon_root(ctx.buf))
            end,
        },
    },
    format_on_save = function(bufnr)
        if vim.g.autoformat == false then return end
        local ft = vim.bo[bufnr].filetype
        if ft == 'rust' or ft == 'lua' then
            return { timeout_ms = 2000, lsp_format = 'fallback' }
        end
    end,
})

-- gq keeps the built-in text formatting (wraps comments at 'textwidth').

m.map(
    { 'n', 'x' },
    '<leader>cf',
    function() conform.format({ async = true, lsp_format = 'fallback' }) end,
    'Format (zon: zlint autofix)'
)
m.nmap('<leader>tf', function()
    vim.g.autoformat = vim.g.autoformat == false
    vim.notify('format on save = ' .. tostring(vim.g.autoformat))
end, 'Toggle format on save (rust, lua)')
