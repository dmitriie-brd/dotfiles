local opt = vim.opt

-- Disable netrw (nvim-tree replaces it). Must happen before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- No remote plugin hosts needed (all plugins are Lua): faster start, clean :checkhealth.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

----------------------------------------
-- General
----------------------------------------
opt.mouse = 'a'
opt.undofile = true -- persistent undo (~/.local/state/nvim/undo)
opt.swapfile = false
opt.confirm = true -- ask instead of failing on :q with unsaved changes
opt.updatetime = 250 -- CursorHold delay (diagnostic float, words highlight)
opt.timeoutlen = 400 -- wait for the next key of a mapping (which-key shows after this)
opt.autoread = true
opt.virtualedit = 'block' -- Ctrl-v block can go past line end
opt.shortmess:append({ I = true, c = true, s = true })
-- System clipboard. Deferred: provider detection costs ~10ms at startup.
vim.schedule(function() opt.clipboard = 'unnamedplus' end)

----------------------------------------
-- Appearance
----------------------------------------
opt.termguicolors = true
opt.number = true
opt.relativenumber = true -- counts for motions: 5j, d3k (toggle: <leader>tn)
opt.signcolumn = 'yes' -- no text shift when signs appear
opt.cursorline = true
opt.colorcolumn = '80' -- zon limit is 79 columns
opt.showmode = false -- lualine shows the mode
opt.laststatus = 3 -- one global statusline
opt.winborder = 'rounded' -- default border for all floating windows
opt.pumheight = 12
opt.synmaxcol = 300 -- no syntax past col 300 (minified files)
opt.title = true
opt.titlestring = '%t - nvim'
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', extends = '›', precedes = '‹' }
opt.fillchars = {
    diff = '╱',
    eob = ' ',
    fold = ' ',
    foldopen = '\u{f078}',
    foldclose = '\u{f054}',
    foldsep = ' ',
}
opt.smoothscroll = true

----------------------------------------
-- Text
----------------------------------------
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.shiftround = true
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

----------------------------------------
-- Folding (treesitter sets foldexpr per buffer; all folds start open)
----------------------------------------
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = '' -- show the first line with syntax highlight

----------------------------------------
-- Scrolling and splits
----------------------------------------
opt.scrolloff = 8
opt.sidescrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = 'screen'

----------------------------------------
-- Search
----------------------------------------
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split' -- live preview of :s in a split

----------------------------------------
-- Files: gf / gF / :find (from the company vimrc)
----------------------------------------
-- Search the current file's dir upward, then the cwd upward.
opt.path = '.;/,;/'
-- 'pkg/util/etask.js:120' -> gf takes only the path, gF also jumps to line 120.
opt.isfname:remove(':')
-- require('./foo') -> gf finds ./foo.js
opt.suffixesadd = { '.js', '.jsx', '.ts', '.tsx', '.json', '.lua' }
opt.wildignore:append({ '*/CVS/*', '*/build.*/*', '*/node_modules/*', '*.o', '*.pyc' })

----------------------------------------
-- Spelling (zon dictionary from the company vimrc)
----------------------------------------
opt.spelllang = { 'en' }
opt.spellfile = vim.fn.expand('~/.zdict.utf-8.add')
opt.spelloptions = 'camel'

----------------------------------------
-- Diff
----------------------------------------
opt.diffopt:remove('linematch:40')
opt.diffopt:append({ 'algorithm:histogram', 'linematch:60', 'context:99999' })
