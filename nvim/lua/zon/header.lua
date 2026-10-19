-- :ZonHeader [node|script|mocha|browser|react]
-- Insert the zon JS file header (company vimrc NewNodeJSHeader(), improved):
--   * the type is guessed from the path when no argument is given;
--   * require('.../util/config.js') uses the correct relative path.
local M = {}

M.kinds = { 'node', 'script', 'mocha', 'browser', 'react', 'jdoc' }

local function rel_config(file, root)
    local dir = vim.fs.dirname(file)
    local target = root .. '/pkg/util/config.js'
    local rel = vim.fs.relpath(dir, target)
    if rel then return './' .. rel end
    -- Walk up from dir until target is below.
    local ups, d = {}, dir
    while d and not vim.startswith(target, d .. '/') do
        table.insert(ups, '..')
        d = vim.fs.dirname(d)
    end
    return table.concat(ups, '/') .. '/' .. target:sub(#d + 2)
end

local function guess(file)
    if file:match('%.test%.js$') or file:match('/test%.js$') then
        return 'mocha'
    elseif file:match('%.jsx$') then
        return 'react'
    elseif file:match('/pub/') then
        return 'browser'
    end
    return 'node'
end

function M.lines(kind, file, root)
    local strict = "'use strict'; /*jslint %s*/"
    if kind == 'jdoc' then
        local u = vim.env.USER
        return { 'TITLE: ', 'AUTHOR: ' .. u, 'OWNER: ' .. u, 'NOTIFY: ' .. u, '' }
    elseif kind == 'node' then
        return {
            '// LICENSE_CODE ZON',
            strict:format('node:true, es9:true'),
            'const E = exports;',
            '',
        }
    elseif kind == 'script' then
        return {
            '#!/usr/bin/env node',
            '// LICENSE_CODE ZON',
            strict:format('node:true, es9:true'),
            ("require('%s');"):format(rel_config(file, root)),
            '',
        }
    elseif kind == 'mocha' then
        local name = vim.fs.basename(file):gsub('%.test%.js$', ''):gsub('%.js$', '')
        return {
            '// LICENSE_CODE ZON',
            strict:format('node:true, mocha:true, es9:true'),
            ("require('%s');"):format(rel_config(file, root)),
            "const assert = require('assert');",
            '',
            ("describe('%s', function(){"):format(name),
            "    it('', ()=>{",
            '    });',
            '});',
        }
    elseif kind == 'browser' then
        return { '// LICENSE_CODE ZON', strict:format('browser:true, es9:true'), '' }
    elseif kind == 'react' then
        return { '// LICENSE_CODE ZON', strict:format('react:true'), '' }
    end
end

function M.insert(kind)
    local file = vim.api.nvim_buf_get_name(0)
    local root = require('zon.root').zon_root() or vim.uv.cwd()
    if kind == nil or kind == '' then kind = vim.bo.filetype == 'jdoc' and 'jdoc' or guess(file) end
    local lines = M.lines(kind, file, root)
    if not lines then return vim.notify('Unknown header kind: ' .. kind, vim.log.levels.ERROR) end
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    if kind == 'jdoc' then
        vim.bo.filetype = 'jdoc'
        vim.api.nvim_win_set_cursor(0, { 1, 7 })
    end
end

return M
