-- augroup('Name', function(autocmd) autocmd('BufEnter', { pattern = '*.js' }, fn_or_cmd) end)
return function(name, setup)
    local group = vim.api.nvim_create_augroup(name, { clear = true })
    setup(function(event, opts, action)
        opts = vim.tbl_extend('force', opts or {}, { group = group })
        if type(action) == 'string' then
            opts.command = action
        else
            opts.callback = action
        end
        return vim.api.nvim_create_autocmd(event, opts)
    end)
    return group
end
