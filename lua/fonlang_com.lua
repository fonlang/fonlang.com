local _M = {}

local controller = require "fonlang_com.controller"
local router = require "router"

local ngx_var = ngx.var
local ngx_req = ngx.req
local r = router.new()

function _M.go()

    -- r:match('GET', "/", controller.index)
    -- r:match('GET', "/blog/", controller.blog_home)
    -- r:match('GET', "/blog/:blog_entry", controller.blog_entry)
    -- r:match('GET', "/blog/category/:category_uri", controller.category_list)

    r:match({
        GET = {
            ['/']   = controller.index,
            ['/blog'] = controller.blog_home,
            ['/blog/'] = controller.blog_home,
            ['/blog/:blog'] = controller.blog_entry,
            ['/blog/category'] = controller.blog_list_by_category,
            ['/blog/category/'] = controller.blog_list_by_category,
            ['/blog/category/:category'] = controller.blog_list_by_category,
        }
    })

    ngx_req.read_body()
    local ok, err = r:execute(
        ngx_var.request_method,
        ngx_var.request_uri,
        ngx_req.get_uri_args(),
        ngx_req.get_post_args()
    )

    if ok then
        ngx.exit(200)
    else
        ngx.exit(404)
        ngx.log(ngx.ERROR, err)
    end
end

return _M
