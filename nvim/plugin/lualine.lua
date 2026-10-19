-- Statusline: mode | VCS (git branch or CVS revision) + changes + diagnostics | file
--             | zon BUILD, LSP clients, filetype | position.
require('helpers.pack').add({ 'nvim-tree/nvim-web-devicons', 'nvim-lualine/lualine.nvim' })

local function cvs_rev() return '\u{e725} CVS ' .. (vim.b.cvs_rev or '') end

local function diff_summary()
    local s = vim.b.minidiff_summary
    if not s then return nil end
    return { added = s.add, modified = s.change, removed = s.delete }
end

local function zon_build()
    if not require('zon.root').zon_root() then return '' end
    return 'BUILD=' .. (require('zon.build').get() or '?')
end

local function lsp_clients()
    local names = {}
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, c.name)
    end
    return #names > 0 and ('\u{f085} ' .. table.concat(names, ',')) or ''
end

require('lualine').setup({
    options = {
        theme = 'gruvbox-material',
        globalstatus = true,
        component_separators = '│',
        section_separators = '',
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = {
            {
                cvs_rev,
                cond = function() return vim.b.cvs_rev ~= nil end,
            },
            'branch',
            { 'diff', source = diff_summary },
            'diagnostics',
        },
        lualine_c = {
            { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' \u{f023}' } },
        },
        lualine_x = { zon_build, lsp_clients, 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
    },
    extensions = { 'nvim-tree', 'quickfix', 'fzf' },
})
