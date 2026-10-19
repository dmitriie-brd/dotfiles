-- fzf-lua: fuzzy finder for everything. In any picker:
--   <CR> open   <C-v>/<C-s>/<C-t> vsplit/split/tab   <Tab> multi-select   <C-q> to quickfix
--   <C-d>/<C-u> scroll preview   <F1> help   <F2> fullscreen   <F4> toggle preview
--   <A-h>/<A-i> toggle hidden/ignored files   live grep: <C-g> switch regex <-> fuzzy
require('helpers.pack').add({ 'nvim-tree/nvim-web-devicons', 'ibhagwan/fzf-lua' })

local fzf = require('fzf-lua')
local actions = require('fzf-lua.actions')
local m = require('helpers.map')
local nmap, xmap = m.nmap, m.xmap
local root = function() return require('zon.root').get() end

-- Never search build trees, CVS metadata and merge backups (.#file), deps, objects.
local excludes = { 'CVS', '.#*', 'build.*', 'node_modules', 'target', '*.o', '*.timestamp', '.git' }
local fd_ex, rg_ex = {}, {}
for _, e in ipairs(excludes) do
    table.insert(fd_ex, '--exclude ' .. vim.fn.shellescape(e))
    table.insert(rg_ex, '-g ' .. vim.fn.shellescape('!' .. e))
end

fzf.setup({
    winopts = {
        backdrop = 80,
        preview = { layout = 'flex', flip_columns = 140 },
    },
    keymap = {
        builtin = {
            true,
            ['<F1>'] = 'toggle-help',
            ['<F2>'] = 'toggle-fullscreen',
            ['<F3>'] = 'toggle-preview-wrap',
            ['<F4>'] = 'toggle-preview',
            ['<C-d>'] = 'preview-page-down',
            ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
            true,
            ['ctrl-d'] = 'preview-page-down',
            ['ctrl-u'] = 'preview-page-up',
            ['ctrl-a'] = 'beginning-of-line',
            ['ctrl-e'] = 'end-of-line',
            ['alt-a'] = 'toggle-all',
        },
    },
    actions = {
        files = {
            true,
            ['ctrl-q'] = actions.file_sel_to_qf,
        },
    },
    files = {
        cwd_prompt = false,
        -- Full paths (no filename-first formatter): pasted paths like pkg/a/b.js match.
        -- On equal scores, prefer matches in the file name part, then shorter paths.
        fzf_opts = { ['--tiebreak'] = 'pathname,length' },
        fd_opts = '--color=never --hidden --type f --type l --follow ' .. table.concat(fd_ex, ' '),
    },
    grep = {
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 '
            .. '--max-filesize=2M --hidden '
            .. table.concat(rg_ex, ' ')
            .. ' -e',
    },
    oldfiles = { include_current_session = true },
    lsp = { includeDeclaration = false, jump1 = true },
    keymaps = { show_details = false },
})
fzf.register_ui_select()

-- Quick access
nmap('<leader><space>', function() fzf.files({ cwd = root() }) end, 'Find files (project root)')
nmap('<leader>/', function() fzf.live_grep({ cwd = root() }) end, 'Grep (project root)')
nmap('<leader>,', fzf.buffers, 'Buffers')
nmap('<leader>:', fzf.command_history, 'Command history')

-- find
nmap('<leader>ff', function() fzf.files({ cwd = root() }) end, 'Files (project root)')
nmap(
    '<leader>fF',
    function() fzf.files({ cwd = vim.fn.expand('%:p:h') }) end,
    "Files (current file's dir)"
)
nmap('<leader>fr', fzf.oldfiles, 'Recent files')
nmap('<leader>fb', fzf.buffers, 'Buffers')
nmap(
    '<leader>fw',
    function() fzf.files({ cwd = root(), query = vim.fn.expand('<cword>') }) end,
    'Files matching word under cursor'
)
nmap('<leader>fh', fzf.helptags, 'Help pages')
nmap('<leader>fk', fzf.keymaps, 'Keymaps')
nmap('<leader>fc', function() fzf.files({ cwd = vim.fn.stdpath('config') }) end, 'Config files')
nmap('<leader>fm', fzf.marks, 'Marks')
nmap('<leader>fj', fzf.jumps, 'Jumplist')
nmap('<leader>f"', fzf.registers, 'Registers')
nmap('<leader>fC', fzf.commands, 'Commands')
nmap('<leader>fH', fzf.highlights, 'Highlight groups')
nmap('<leader>fR', fzf.resume, 'Resume last picker')

-- search
nmap('<leader>sg', function() fzf.live_grep({ cwd = root() }) end, 'Grep (project root)')
nmap(
    '<leader>sG',
    function() fzf.live_grep({ cwd = vim.fn.expand('%:p:h') }) end,
    "Grep (current file's dir)"
)
nmap('<leader>sw', function() fzf.grep_cword({ cwd = root() }) end, 'Grep word under cursor')
xmap('<leader>sw', function() fzf.grep_visual({ cwd = root() }) end, 'Grep selection')
nmap('<leader>sb', fzf.blines, 'Lines in buffer')
nmap('<leader>ss', fzf.lsp_document_symbols, 'Symbols (buffer)')
nmap('<leader>sS', fzf.lsp_live_workspace_symbols, 'Symbols (workspace)')
nmap('<leader>sd', fzf.diagnostics_document, 'Diagnostics (buffer)')
nmap('<leader>sD', fzf.diagnostics_workspace, 'Diagnostics (workspace)')
nmap('<leader>sq', fzf.quickfix, 'Quickfix list')
nmap('<leader>sQ', fzf.quickfix_stack, 'Quickfix history')
nmap('<leader>sl', fzf.loclist, 'Location list')
nmap('<leader>s/', fzf.search_history, 'Search history')
nmap('<leader>sh', fzf.help_tags, 'Help pages')
nmap('<leader>sm', fzf.manpages, 'Man pages')
nmap('<leader>sR', fzf.resume, 'Resume last picker')

-- git (git repos only; for zon use <leader>z)
nmap('<leader>gs', fzf.git_status, 'Git status')
nmap('<leader>gc', fzf.git_commits, 'Git commits (repo)')
nmap('<leader>gC', fzf.git_bcommits, 'Git commits (buffer)')
nmap('<leader>gB', fzf.git_branches, 'Git branches')
