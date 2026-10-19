-- Core keymaps (no plugins). Plugin keymaps live next to each plugin in plugin/*.lua.
local m = require('helpers.map')
local map, nmap, xmap, imap, cmap, tmap = m.map, m.nmap, m.xmap, m.imap, m.cmap, m.tmap

----------------------------------------
-- General
----------------------------------------
imap('jj', '<Esc>', 'Leave insert mode')
nmap('<Esc>', '<cmd>nohlsearch<CR><Esc>', 'Clear search highlight')
tmap('<Esc><Esc>', '<C-\\><C-n>', 'Leave terminal mode')
nmap('<leader>qq', '<cmd>qa<CR>', 'Quit all')
nmap('<leader>qw', '<cmd>wa<CR>', 'Write all buffers')

-- Paste over a selection without losing the register (old .vimrc: xnoremap p pgvy).
xmap('p', 'P', 'Paste without yanking the replaced text')

-- Keep the selection after indent.
xmap('<', '<gv', 'Indent left, keep selection')
xmap('>', '>gv', 'Indent right, keep selection')

----------------------------------------
-- Search: centered results, very magic regex
----------------------------------------
nmap('n', 'nzzzv', 'Next match (centered)')
nmap('N', 'Nzzzv', 'Previous match (centered)')
nmap('*', '*zzzv', 'Search word forward (centered)')
nmap('#', '#zzzv', 'Search word backward (centered)')
nmap('g*', 'g*zzzv', 'Search partial word forward (centered)')
nmap('g#', 'g#zzzv', 'Search partial word backward (centered)')
-- \v = "very magic": (a|b)+ works without backslashes, like JS regex.
nmap('/', '/\\v', 'Search forward (very magic)', { silent = false })
nmap('?', '?\\v', 'Search backward (very magic)', { silent = false })
cmap('%s/', '%s/\\v', 'Substitute (very magic)', { silent = false })

----------------------------------------
-- Windows
----------------------------------------
nmap('<C-h>', '<C-w>h', 'Go to left window')
nmap('<C-j>', '<C-w>j', 'Go to lower window')
nmap('<C-k>', '<C-w>k', 'Go to upper window')
nmap('<C-l>', '<C-w>l', 'Go to right window')
-- Resize. Note: replaces built-in - + (line motions) and = (re-indent operator).
nmap('-', '3<C-w>-', 'Window: reduce height')
nmap('=', '3<C-w>+', 'Window: increase height')
nmap('_', '3<C-w><', 'Window: reduce width')
nmap('+', '3<C-w>>', 'Window: increase width')
map({ 'n', 'x' }, '<leader>=', '=', 'Re-indent (the = operator)')
nmap('<leader>w', '<C-w>', 'Window commands (<C-w>)', { remap = true })

----------------------------------------
-- Move lines
----------------------------------------
nmap('<A-j>', '<cmd>m .+1<CR>==', 'Move line down')
nmap('<A-k>', '<cmd>m .-2<CR>==', 'Move line up')
imap('<A-j>', '<Esc><cmd>m .+1<CR>==gi', 'Move line down')
imap('<A-k>', '<Esc><cmd>m .-2<CR>==gi', 'Move line up')
xmap('<A-j>', ":m '>+1<CR>gv=gv", 'Move selection down')
xmap('<A-k>', ":m '<-2<CR>gv=gv", 'Move selection up')

----------------------------------------
-- Buffers ([b ]b [q ]q [l ]l are built in)
----------------------------------------
nmap('<leader>bb', '<cmd>e #<CR>', 'Switch to alternate buffer')
nmap('<leader>bn', '<cmd>enew<CR>', 'New empty buffer')

----------------------------------------
-- Diagnostics ([d ]d [D ]D and <C-w>d are built in)
----------------------------------------
nmap('<leader>cd', vim.diagnostic.open_float, 'Line diagnostics (float)')
nmap(
    '[e',
    function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
    'Previous error'
)
nmap(
    ']e',
    function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
    'Next error'
)

----------------------------------------
-- Toggles
----------------------------------------
local function toggle(name, scope)
    return function()
        local o = (scope or vim.wo)
        o[name] = not o[name]
        vim.notify(name .. ' = ' .. tostring(o[name]))
    end
end
nmap('<leader>tw', toggle('wrap'), 'Toggle wrap')
nmap('<leader>ts', toggle('spell'), 'Toggle spell')
nmap('<leader>tn', toggle('relativenumber'), 'Toggle relative numbers')
nmap('<leader>tl', toggle('list'), 'Toggle invisible chars')
nmap('<leader>th', function()
    local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(on, { bufnr = 0 })
    vim.notify('inlay hints = ' .. tostring(on))
end, 'Toggle inlay hints')
nmap('<leader>td', function()
    local on = not vim.diagnostic.is_enabled()
    vim.diagnostic.enable(on)
    vim.notify('diagnostics = ' .. tostring(on))
end, 'Toggle diagnostics')
nmap('<leader>tv', function()
    local vt = vim.diagnostic.config().virtual_text
    local lines = vim.diagnostic.config().virtual_lines
    if vt and not lines then
        vim.diagnostic.config({ virtual_text = false, virtual_lines = { current_line = true } })
        vim.notify('diagnostics: virtual lines (current line)')
    else
        vim.diagnostic.config({ virtual_text = { current_line = true }, virtual_lines = false })
        vim.notify('diagnostics: virtual text (current line)')
    end
end, 'Toggle diagnostic style (text / lines)')
nmap('<leader>ti', function()
    if vim.o.diffopt:find('iwhite') then
        vim.opt.diffopt:remove('iwhite')
    else
        vim.opt.diffopt:append('iwhite')
    end
    vim.notify('diffopt = ' .. vim.o.diffopt)
end, 'Toggle diff: ignore whitespace')
nmap('<leader>tu', function()
    vim.cmd.packadd('nvim.undotree')
    vim.cmd('Undotree')
end, 'Toggle undo tree')

----------------------------------------
-- Diff mode helpers (company vimrc: Tab / S-Tab jump between changes)
----------------------------------------
nmap(
    '<Tab>',
    function() return vim.wo.diff and ']czz' or '<Tab>' end,
    'Diff: next change (only in diff mode)',
    { expr = true }
)
nmap(
    '<S-Tab>',
    function() return vim.wo.diff and '[czz' or '<S-Tab>' end,
    'Diff: previous change (only in diff mode)',
    { expr = true }
)
