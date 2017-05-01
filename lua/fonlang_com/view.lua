local _M = {}

local template = require "resty.template"

function _M.new(view, layout) 
    return template.new(view, layout)
end

return _M
