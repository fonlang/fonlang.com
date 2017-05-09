local _M = {}

local template = require "resty.template"
local helper = require "qian.helper"
template.helper = helper

function _M.new(view, layout) 
    -- todo: add config support
    return template.new(view, layout)
end

return _M
