local _M = {}

local template = require "resty.template"
local inspect = require "inspect"
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
    return false
end

function _M.is_category() 
    return false
end

return template.helper
