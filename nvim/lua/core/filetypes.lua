-- Filetype detection for zon files (company vimrc).
vim.filetype.add({
    extension = {
        jdoc = 'jdoc',
        txt = function(_, buf)
            -- jdoc documents are .txt files with TITLE: on line 1 or 2.
            local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
            for _, l in ipairs(lines) do
                if l:match('^[Tt][Ii][Tt][Ll][Ee]:') then return 'jdoc' end
            end
            return 'text'
        end,
    },
    filename = {
        ['.cvsignore'] = 'gitignore',
        ['Jakefile'] = 'javascript',
    },
    pattern = {
        ['.*/system/agent/upstart/.*%.conf'] = 'upstart',
        ['%.makeflags%..*'] = 'conf',
        ['.*%.makeflags%..*'] = 'conf',
    },
})
