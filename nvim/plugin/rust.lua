-- Rust: rustaceanvim (rust-analyzer + clippy on save) and crates.nvim (Cargo.toml).
-- rust-analyzer comes from rustup (`rustup component add rust-analyzer`), not mason.
require('helpers.pack').add({
    { src = 'mrcjkb/rustaceanvim', version = vim.version.range('9') },
})
require('helpers.pack').add({ { src = 'saecki/crates.nvim', version = 'stable' } }, { lazy = true })

local m = require('helpers.map')
local augroup = require('helpers.augroup')

vim.g.rustaceanvim = {
    tools = { test_executor = 'background' },
    server = {
        default_settings = {
            ['rust-analyzer'] = {
                cargo = { features = 'all' },
                check = { command = 'clippy' },
                imports = { granularity = { group = 'crate' } },
            },
        },
    },
}

augroup('RustKeys', function(autocmd)
    autocmd('FileType', { pattern = 'rust' }, function(ev)
        local function bmap(lhs, cmd, desc)
            m.nmap(lhs, '<cmd>RustLsp ' .. cmd .. '<CR>', desc, { buffer = ev.buf })
        end
        bmap('<leader>rr', 'runnables', 'Rust runnables')
        bmap('<leader>rR', 'runnables last', 'Rust: rerun last runnable')
        bmap('<leader>rt', 'testables', 'Rust testables')
        bmap('<leader>rT', 'testables last', 'Rust: rerun last test')
        bmap('<leader>rm', 'expandMacro', 'Expand macro')
        bmap('<leader>re', 'explainError', 'Explain error')
        bmap('<leader>rd', 'renderDiagnostic', 'Render diagnostic (like cargo)')
        bmap('<leader>rc', 'openCargo', 'Open Cargo.toml')
        bmap('<leader>ro', 'openDocs', 'Open docs.rs for symbol')
        bmap('<leader>rp', 'parentModule', 'Parent module')
        bmap('<leader>rj', 'joinLines', 'Join lines (smart)')
        bmap('<leader>ca', 'codeAction', 'Code action (grouped)')
        m.nmap(
            'K',
            function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
            'Hover (with actions)',
            { buffer = ev.buf }
        )
    end)
end)

----------------------------------------
-- crates.nvim: versions, completion, upgrades in Cargo.toml
----------------------------------------
-- Set up on the first Cargo.toml (crates attaches to the buffer on BufRead).
augroup('CratesKeys', function(autocmd)
    autocmd('BufRead', { pattern = 'Cargo.toml' }, function(ev)
        local crates = require('crates')
        if not vim.g.crates_setup_done then
            vim.g.crates_setup_done = true
            crates.setup({
                lsp = { enabled = true, actions = true, completion = true, hover = true },
            })
        end
        local function bmap(lhs, fn, desc) m.nmap(lhs, fn, desc, { buffer = ev.buf }) end
        bmap('<leader>rv', crates.show_versions_popup, 'Crate versions')
        bmap('<leader>rf', crates.show_features_popup, 'Crate features')
        bmap('<leader>ru', crates.upgrade_crate, 'Upgrade crate')
        bmap('<leader>rU', crates.upgrade_all_crates, 'Upgrade all crates')
        bmap('<leader>rD', crates.open_documentation, 'Crate documentation')
    end)
end)
