local _M = {}

local template = require "resty.template"
local helper = require "fonlang_com.helper"

template.helper = helper
template.util = util

function _M.new(view, layout) 
    -- todo: add config support
    return template.new(view, layout)
end

return _M
