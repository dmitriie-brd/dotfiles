-- Linting (nvim-lint): results are shown as diagnostics.
--   zon JS/TS: zlint -c on open and on save (zlint reads the file from disk).
--   Other JS/TS projects: eslint, only when the project has an eslint config.
require('helpers.pack').add({ 'mfussenegger/nvim-lint' })

local lint = require('lint')
local augroup = require('helpers.augroup')

lint.linters.zlint = require('zon.zlint').linter()

local js = { javascript = true, javascriptreact = true, typescript = true, typescriptreact = true }
local eslint_configs = {
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.json',
    '.eslintrc.yml',
}

local function run(buf)
    if vim.bo[buf].buftype ~= '' or not js[vim.bo[buf].filetype] then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' or name:match('^%w%w+://') then return end
    if require('zon.root').zon_root(buf) then
        if vim.g.zlint_live ~= false then lint.try_lint('zlint') end
    elseif vim.fs.root(buf, eslint_configs) then
        lint.try_lint('eslint')
    end
end

augroup('Lint', function(autocmd)
    autocmd({ 'FileType', 'BufWritePost' }, {}, function(ev)
        -- try_lint works on the current buffer
        if ev.buf == vim.api.nvim_get_current_buf() then run(ev.buf) end
    end)
end)
