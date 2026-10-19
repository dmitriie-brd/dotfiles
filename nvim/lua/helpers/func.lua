local M = {}

-- partial(f, a, b)(c) == f(a, b, c)
function M.partial(fn, ...)
    local args = { ... }
    return function(...)
        local all = vim.list_extend(vim.list_slice(args), { ... })
        return fn(unpack(all))
    end
end

return M
