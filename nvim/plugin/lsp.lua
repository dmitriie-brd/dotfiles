-- LSP: native client (vim.lsp.config / vim.lsp.enable) + server defaults from nvim-lspconfig.
-- Servers and tools are installed by mason into ~/.local/share/nvim/mason (:Mason).
--
-- Built-in LSP keys (Neovim 0.11+):
--   K hover   grn rename   gra code action   grr references   gri implementation
--   grt type definition   gO document symbols   <C-s> (insert) signature help
--   [d ]d diagnostics   <C-w>d diagnostic float
-- Added here: gd definition, gD declaration, <leader>c* aliases (which-key discoverable).
require('helpers.pack').add({
    'neovim/nvim-lspconfig',
    'mason-org/mason.nvim',
    'b0o/SchemaStore.nvim',
    'folke/lazydev.nvim',
})

local m = require('helpers.map')
local augroup = require('helpers.augroup')

----------------------------------------
-- Mason: install missing tools in the background.
----------------------------------------
require('mason').setup()
local ensure = { 'vtsls', 'lua-language-server', 'json-lsp', 'html-lsp', 'css-lsp', 'stylua' }
vim.schedule(function()
    local registry = require('mason-registry')
    registry.refresh(function()
        for _, name in ipairs(ensure) do
            local ok, pkg = pcall(registry.get_package, name)
            if ok and not pkg:is_installed() and not pkg:is_installing() then
                vim.notify('mason: installing ' .. name)
                pkg:install()
            end
        end
    end)
end)

----------------------------------------
-- Diagnostics
----------------------------------------
local sev = vim.diagnostic.severity
vim.diagnostic.config({
    severity_sort = true,
    underline = { severity = { min = sev.WARN } },
    virtual_text = { current_line = true, source = 'if_many', spacing = 2 },
    virtual_lines = false,
    update_in_insert = false,
    float = { source = 'if_many', header = '', prefix = '' },
    signs = {
        text = {
            [sev.ERROR] = '\u{f057} ',
            [sev.WARN] = '\u{f071} ',
            [sev.INFO] = '\u{f05a} ',
            [sev.HINT] = '\u{f0eb} ',
        },
    },
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor', focus = false })
        end,
    },
})

----------------------------------------
-- Servers
----------------------------------------
-- TypeScript/JavaScript. In zon the root is the checkout root (no jsconfig): tsserver
-- builds an inferred project from the open files and their require() chains.
local vtsls_default_root = vim.lsp.config.vtsls.root_dir
-- Hide noisy suggestions: 80001 "CommonJS module may be converted to ES module",
-- 80002 "may be converted to a class", 80006/80007 "may be converted to async / await".
local ts_ignore = { [80001] = true, [80002] = true, [80006] = true, [80007] = true }
vim.lsp.config('vtsls', {
    handlers = {
        ['textDocument/publishDiagnostics'] = function(err, res, ctx)
            if res and res.diagnostics then
                res.diagnostics = vim.tbl_filter(
                    function(d) return not ts_ignore[d.code] end,
                    res.diagnostics
                )
            end
            return vim.lsp.diagnostic.on_publish_diagnostics(err, res, ctx)
        end,
    },
    root_dir = function(bufnr, on_dir)
        local zon = require('zon.root').zon_root(bufnr)
        if zon then return on_dir(zon) end
        return vtsls_default_root(bufnr, on_dir)
    end,
    settings = {
        complete_function_calls = false,
        vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
                maxInlayHintLength = 30,
                completion = { enableServerSideFuzzyMatch = true },
            },
        },
        typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            tsserver = { maxTsServerMemory = 8192 },
            inlayHints = {
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
        },
        javascript = {
            updateImportsOnFileMove = { enabled = 'always' },
            inlayHints = {
                parameterNames = { enabled = 'literals' },
                functionLikeReturnTypes = { enabled = true },
            },
        },
        ['js/ts'] = {
            implicitProjectConfig = { checkJs = false, target = 'ES2022', module = 'CommonJS' },
        },
    },
})

vim.lsp.config('jsonls', {
    before_init = function(_, config)
        config.settings = vim.tbl_deep_extend('force', config.settings or {}, {
            json = { schemas = require('schemastore').json.schemas(), validate = { enable = true } },
        })
    end,
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = 'Replace' },
            hint = { enable = true },
        },
    },
})
require('lazydev').setup({
    library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
})

-- rust-analyzer is started by rustaceanvim (plugin/rust.lua), not here.
vim.lsp.enable({ 'vtsls', 'jsonls', 'lua_ls', 'html', 'cssls' })

----------------------------------------
-- Keymaps on attach
----------------------------------------
augroup('LspAttachKeys', function(autocmd)
    autocmd('LspAttach', {}, function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local buf = ev.buf
        local fzf = require('fzf-lua')
        local function bmap(mode, lhs, rhs, desc) m.map(mode, lhs, rhs, desc, { buffer = buf }) end
        bmap('n', 'gd', fzf.lsp_definitions, 'Go to definition')
        bmap('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
        bmap('n', 'grr', fzf.lsp_references, 'References')
        bmap('n', 'gri', fzf.lsp_implementations, 'Implementations')
        bmap('n', 'grt', fzf.lsp_typedefs, 'Type definition')
        bmap({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
        bmap('n', '<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
        bmap('n', '<leader>cl', '<cmd>checkhealth vim.lsp<CR>', 'LSP info')
        bmap('n', '<leader>cL', '<cmd>lsp restart<CR>', 'Restart LSP')
        if client and client.name == 'vtsls' then
            bmap(
                'n',
                '<leader>co',
                function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = { only = { 'source.organizeImports' }, diagnostics = {} },
                    })
                end,
                'Organize imports'
            )
            bmap(
                'n',
                '<leader>cM',
                function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = { only = { 'source.addMissingImports.ts' }, diagnostics = {} },
                    })
                end,
                'Add missing imports'
            )
            bmap(
                'n',
                '<leader>cu',
                function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = { only = { 'source.removeUnused.ts' }, diagnostics = {} },
                    })
                end,
                'Remove unused imports'
            )
        end
    end)
end)
