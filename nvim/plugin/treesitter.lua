-- Treesitter: parsers (nvim-treesitter), highlighting/folds (built into nvim),
-- code text objects (textobjects), sticky context, JSX tag autoclose, JSX comments.
--
-- Text objects (use with any operator: daf, cif, vac, yaa ...):
--   af/if function   ac/ic class   aa/ia argument   ao/io conditional   al/il loop
-- Motions: ]f [f next/prev function start, ]F [F function end, ]C [C class
-- Swap:    <leader>cx / <leader>cX swap argument with next / previous
vim.g.no_plugin_maps = true -- built-in ftplugins: no conflicting ]] [[ mappings

require('helpers.pack').add({
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'windwp/nvim-ts-autotag',
    'folke/ts-comments.nvim',
})

local augroup = require('helpers.augroup')
local m = require('helpers.map')

local parsers = {
    'javascript',
    'typescript',
    'tsx',
    'jsdoc',
    'json',
    'json5',
    'rust',
    'toml',
    'lua',
    'luadoc',
    'vim',
    'vimdoc',
    'query',
    'html',
    'css',
    'scss',
    'xml',
    'bash',
    'make',
    'dockerfile',
    'yaml',
    'ini',
    'sql',
    'c',
    'php',
    'markdown',
    'markdown_inline',
    'regex',
    'comment',
    'diff',
    'gitignore',
}
require('nvim-treesitter').install(parsers)

-- Keep parsers in sync with the plugin after vim.pack.update().
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
            vim.schedule(function() vim.cmd('TSUpdate') end)
        end
    end,
})

-- Start treesitter for every filetype that has a parser.
augroup('TreesitterStart', function(autocmd)
    autocmd('FileType', {}, function(ev)
        if vim.b[ev.buf].bigfile then return end
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then return end
        vim.wo[0][0].foldmethod = 'expr'
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end)
end)

----------------------------------------
-- Text objects
----------------------------------------
require('nvim-treesitter-textobjects').setup({
    select = { lookahead = true },
    move = { set_jumps = true },
})

local select = require('nvim-treesitter-textobjects.select')
local move = require('nvim-treesitter-textobjects.move')
local swap = require('nvim-treesitter-textobjects.swap')

local objects = {
    f = { 'function', 'Function' },
    c = { 'class', 'Class' },
    a = { 'parameter', 'Argument' },
    o = { 'conditional', 'Conditional' },
    l = { 'loop', 'Loop' },
}
for key, o in pairs(objects) do
    m.map(
        { 'x', 'o' },
        'a' .. key,
        function() select.select_textobject('@' .. o[1] .. '.outer', 'textobjects') end,
        o[2] .. ' (outer)'
    )
    m.map(
        { 'x', 'o' },
        'i' .. key,
        function() select.select_textobject('@' .. o[1] .. '.inner', 'textobjects') end,
        o[2] .. ' (inner)'
    )
end

local nxo = { 'n', 'x', 'o' }
m.map(
    nxo,
    ']f',
    function() move.goto_next_start('@function.outer', 'textobjects') end,
    'Next function start'
)
m.map(
    nxo,
    '[f',
    function() move.goto_previous_start('@function.outer', 'textobjects') end,
    'Previous function start'
)
m.map(
    nxo,
    ']F',
    function() move.goto_next_end('@function.outer', 'textobjects') end,
    'Next function end'
)
m.map(
    nxo,
    '[F',
    function() move.goto_previous_end('@function.outer', 'textobjects') end,
    'Previous function end'
)
m.map(nxo, ']C', function() move.goto_next_start('@class.outer', 'textobjects') end, 'Next class')
m.map(
    nxo,
    '[C',
    function() move.goto_previous_start('@class.outer', 'textobjects') end,
    'Previous class'
)
m.map(
    nxo,
    ']a',
    function() move.goto_next_start('@parameter.inner', 'textobjects') end,
    'Next argument'
)
m.map(
    nxo,
    '[a',
    function() move.goto_previous_start('@parameter.inner', 'textobjects') end,
    'Previous argument'
)

m.nmap('<leader>cx', function() swap.swap_next('@parameter.inner') end, 'Swap argument with next')
m.nmap(
    '<leader>cX',
    function() swap.swap_previous('@parameter.inner') end,
    'Swap argument with previous'
)

----------------------------------------
-- Sticky context: current function/class header at the top.
----------------------------------------
local ctx = require('treesitter-context')
ctx.setup({ max_lines = 3, multiline_threshold = 1, trim_scope = 'inner' })
m.nmap('[x', function() ctx.go_to_context(vim.v.count1) end, 'Go to context (enclosing function)')
m.nmap('<leader>tc', function() ctx.toggle() end, 'Toggle sticky context')

----------------------------------------
-- JSX/HTML tags: autoclose + autorename. Comments: gc uses {/* */} in JSX.
----------------------------------------
require('nvim-ts-autotag').setup({})
require('ts-comments').setup({})
