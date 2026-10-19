local augroup = require('helpers.augroup')

augroup('CoreAutocmds', function(autocmd)
    -- Flash the yanked text.
    autocmd('TextYankPost', {}, function() vim.hl.on_yank({ timeout = 200 }) end)

    -- Equal splits when the terminal is resized.
    autocmd('VimResized', {}, 'tabdo wincmd =')

    -- Reload files changed outside nvim (cvs update, zlint autofix, git checkout).
    autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {}, function()
        if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
    end)

    -- Jump to the last cursor position when a file is opened (company vimrc).
    autocmd('BufReadPost', {}, function(ev)
        local ft = vim.bo[ev.buf].filetype
        if ft == 'gitcommit' or ft == 'commit' or vim.b[ev.buf].last_loc_done then return end
        vim.b[ev.buf].last_loc_done = true
        local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end)

    -- Close helper windows with q.
    autocmd('FileType', {
        pattern = {
            'help',
            'qf',
            'man',
            'checkhealth',
            'nvim-pack',
            'notify',
            'grug-far',
            'cvsannotate',
        },
    }, function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set(
            'n',
            'q',
            '<cmd>close<CR>',
            { buffer = ev.buf, silent = true, desc = 'Close window' }
        )
    end)

    -- Create missing parent directories on save.
    autocmd('BufWritePre', {}, function(ev)
        if ev.match:match('^%w%w+:[\\/][\\/]') then return end
        local file = vim.uv.fs_realpath(ev.match) or ev.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end)

    -- Terminal buffers: no numbers, start in insert mode.
    autocmd('TermOpen', {}, function()
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = 'no'
    end)
end)

----------------------------------------
-- Bad whitespace and long lines (company vimrc Mark_error()):
--   * characters past column 79 in zon code files;
--   * trailing whitespace (not while you type at the end of the line);
--   * non-breaking spaces (U+00A0).
----------------------------------------
local overlength_ft = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
    json = true,
    css = true,
    less = true,
    scss = true,
    sh = true,
    bash = true,
    c = true,
    cpp = true,
    python = true,
    perl = true,
    make = true,
    text = true,
    jdoc = true,
    java = true,
    cs = true,
}

local function set_hl()
    vim.api.nvim_set_hl(0, 'BadWhitespace', { bg = '#5c2a2a' })
    vim.api.nvim_set_hl(0, 'OverLength', { bg = '#5c2a2a' })
end
set_hl()

local function apply_matches()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    for _, id in ipairs(vim.w[win].bad_ws_ids or {}) do
        pcall(vim.fn.matchdelete, id, win)
    end
    local ids = {}
    local bo = vim.bo[buf]
    if
        bo.buftype == ''
        and bo.modifiable
        and bo.filetype ~= 'markdown'
        and not vim.wo[win].diff
    then
        table.insert(ids, vim.fn.matchadd('BadWhitespace', [[\s\+\%#\@<!$]], -1))
        table.insert(ids, vim.fn.matchadd('BadWhitespace', [[\%u00a0]], -1))
        if overlength_ft[bo.filetype] and require('zon.root').zon_root(buf) then
            table.insert(ids, vim.fn.matchadd('OverLength', [[\%>79v.\+]], -1))
        end
    end
    vim.w[win].bad_ws_ids = ids
end

augroup('BadWhitespace', function(autocmd)
    autocmd('ColorScheme', {}, set_hl)
    autocmd({ 'BufWinEnter', 'WinEnter', 'FileType', 'OptionSet' }, {}, function(ev)
        if ev.event == 'OptionSet' and ev.match ~= 'diff' then return end
        apply_matches()
    end)
end)
