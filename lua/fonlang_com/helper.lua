local _M = {}

local inspect = require "inspect"
local template = require "resty.template"

local ngx_var = ngx.var
local re_match = ngx.re.match

template.helper = _M

function _M.favicon_tag(path) 
    local pa = '/images/favicon.ico'
    if path == nil or path == '' then
        pa = path
    end

    return '<link rel="shortcut ico" href="' .. pa  .. '">'
end

function _M.is_tag()
    return false
end

function _M.is_archive()
    local uri = ngx_var.uri

    local match_table = {}
    local m = re_match(uri, [[ ^ / blog / archive / (?: \d+ /)? $ ]], 
                      'jox', nil, match_table) 
    print (inspect(m))
    if m then 
        return true
    end

    return false 
end

function _M.is_category() 
    local uri = ngx_var.uri

    local match_table = {}
    local m = re_match(uri, [[ ^ / blog / category / (?: [\w-]+ /)? $ ]], 
                      'jox', nil, match_table) 
    print (inspect(m))
    if m then 
        return true
    end

    return false 
end

return template.helper
