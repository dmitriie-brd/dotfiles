-- zon integration: CVS, zlint, zmocha, BUILD, headers. All keys under <leader>z.
local m = require('helpers.map')
local augroup = require('helpers.augroup')
local nmap = m.nmap

local cmd = vim.api.nvim_create_user_command

----------------------------------------
-- CVS
----------------------------------------
local function cvs_diff(which)
    return function() require('zon.cvs.diff').open(nil, which) end
end

nmap('<leader>zd', cvs_diff('BASE'), 'CVS: diff with BASE (your checkout revision)')
nmap('<leader>zD', cvs_diff('HEAD'), 'CVS: diff with HEAD (latest on server)')
nmap('<leader>za', function() require('zon.cvs.annotate').open() end, 'CVS: annotate (toggle)')
nmap('<leader>zb', function() require('zon.cvs.annotate').blame() end, 'CVS: blame line (float)')
nmap('<leader>zh', function() require('zon.cvs.log').history() end, 'CVS: file history')
nmap(
    '<leader>zm',
    function() require('zon.cvs.status').picker() end,
    'CVS: modified files (local, fast)'
)
nmap(
    '<leader>zs',
    function() require('zon.cvs.status').remote() end,
    "CVS: status of current file's dir (network)"
)

cmd(
    'CvsDiff',
    function(o) require('zon.cvs.diff').open(nil, o.args ~= '' and o.args or 'BASE') end,
    { nargs = '?', desc = 'CVS diff with BASE, HEAD or a revision' }
)
cmd(
    'CvsAnnotate',
    function() require('zon.cvs.annotate').open() end,
    { desc = 'CVS annotate with full names' }
)
cmd('CvsLog', function() require('zon.cvs.log').history() end, { desc = 'CVS file history' })
cmd(
    'CvsModified',
    function() require('zon.cvs.status').picker() end,
    { desc = 'CVS modified files' }
)
cmd(
    'CvsStatus',
    function(o)
        require('zon.cvs.status').remote(o.args ~= '' and vim.fn.fnamemodify(o.args, ':p') or nil)
    end,
    { nargs = '?', complete = 'dir', desc = 'cvs -n update (network)' }
)
cmd(
    'CvsRev',
    function(o) require('zon.cvs.diff').open_rev(nil, o.args) end,
    { nargs = 1, desc = 'Open the current file at a revision' }
)

----------------------------------------
-- zlint / zmocha / BUILD
----------------------------------------
nmap('<leader>zl', function() require('zon.zlint').current({}) end, 'zlint: file -> quickfix')
nmap(
    '<leader>zc',
    function() require('zon.zlint').current({ '-c' }) end,
    'zlint -c: file -> quickfix (required before handoff)'
)
nmap(
    '<leader>zM',
    function() require('zon.zlint').modified() end,
    'zlint -c: all CVS-modified files -> quickfix'
)
nmap(
    '<leader>zf',
    function() require('conform').format({ async = true, formatters = { 'zlint_fix' } }) end,
    'zlint autofix (eslint --fix, zon rules)'
)
nmap('<leader>zL', function()
    vim.g.zlint_live = vim.g.zlint_live == false
    if not vim.g.zlint_live then vim.diagnostic.reset(require('lint').get_namespace('zlint')) end
    vim.notify('zlint live diagnostics = ' .. tostring(vim.g.zlint_live))
end, 'zlint: toggle live diagnostics')

nmap('<leader>zt', function() require('zon.zmocha').file() end, 'zmocha: run test file')
nmap('<leader>zT', function() require('zon.zmocha').nearest() end, 'zmocha: run test under cursor')
nmap('<leader>zr', function() require('zon.zmocha').last() end, 'zmocha: rerun last')
nmap(
    '<leader>zA',
    function() require('zon.zmocha').alternate() end,
    'Alternate file (source <-> test)'
)
cmd(
    'A',
    function() require('zon.zmocha').alternate() end,
    { desc = 'Alternate file (source <-> test)' }
)

nmap('<leader>zB', function() require('zon.build').select() end, 'Select zon BUILD')
cmd('ZonBuild', function(o) require('zon.build').select(o.args) end, {
    nargs = '?',
    complete = function()
        local root = require('zon.root').zon_root()
        return root
                and vim.tbl_map(function(b) return b.name end, require('zon.build').list(root))
            or {}
    end,
    desc = 'Select zon BUILD for zmocha',
})

----------------------------------------
-- Headers
----------------------------------------
nmap('<leader>zn', function() require('zon.header').insert() end, 'Insert zon file header')
cmd('ZonHeader', function(o) require('zon.header').insert(o.args) end, {
    nargs = '?',
    complete = function() return require('zon.header').kinds end,
    desc = 'Insert zon header: node|script|mocha|browser|react|jdoc',
})

----------------------------------------
-- Buffer setup for zon JS files
----------------------------------------
augroup('ZonBuffer', function(autocmd)
    autocmd('FileType', {
        pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    }, function(ev)
        if not require('zon.root').zon_root(ev.buf) then return end
        vim.bo[ev.buf].textwidth = 79 -- gq and comments wrap at the zon limit
        vim.api.nvim_buf_call(ev.buf, function()
            vim.cmd('compiler zlint') -- :make = zlint, :make -c = conventions pass
        end)
    end)
end)
