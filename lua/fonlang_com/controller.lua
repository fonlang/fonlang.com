local _M = {}

local view = require "fonlang_com.view"
local model = require "fonlang_com.model"
local inspect = require "inspect"
local cjson = require "cjson"

local re_find = ngx.re.find
local re_match = ngx.re.match
local ngx_var = ngx.var
local resp_header = ngx.header
local match_table = {}


local function get_category_uri(category, categories) 
    for _, v in ipairs(categories) do 
        if v["category"] == category then
            -- print (v["category"] .. " ==> " .. category .. " ==> " .. v["uri"])
            return v["uri"]
        end
    end

    return ''
end


function _M.run()
    local uri = ngx_var.uri
    print(uri)

    -- /
    if uri == "/" then
        resp_header["Cache-Control"] = "max-age=3600"
        return ngx.redirect("/blog/", 302)
    end

    -- /blog
    if uri == "/blog" or uri == "/blog/" then
        local blogs = model.list_latest_created_blogs()
        local categories = model.list_all_categroies()

        local v = view.new("blog-home.html", "layout.html")
        v.title = "Fong | 与癌症斗争着的编码者"
        v.blogs = blogs
        v.categories = categories
        v.breadcrumbs = { 
            { category = "首页", uri = "/blog/" },
            { category = "博客", uri = "/blog/" },
            { category = "全部文章" }
        }
        v:render()
        return
    end

    -- /blog/{blog_entry_name}
    local m = re_match(uri,
                       [[ ^ / blog / ( [\w-]+ ) $ ]],
                       'jox', nil, match_table)
    if m then
        local blog = model.get_blog_by_uri(uri)
        if blog then
            local categories = model.list_all_categroies()
            local category_uri = get_category_uri(blog["category"], categories)

            local v = view.new("blog-entry.html", "layout.html")
            v.title = "Fong | " .. blog['title']
            v.blog = blog
            v.categories = categories
            v.breadcrumbs = { 
                { category = "首页", uri = "/blog/" },
                { category = "博客", uri = "/blog/" },
                { category = blog["category"], uri = category_uri },
                { category = blog["title"] }
            }
            v:render()
            return
        else
            ngx.exit(500)
        end
    end

    -- /blog/category/{category_uri}}
    m = re_match(uri,
                 [[ ^ ( / blog / category / [\w-]* ) $ ]],
                 'jox', nil, match_table)
    if m then
        local cur_uri = m[1]
        local blogs = model.list_blogs_by_category_uri(cur_uri)
        local categories = model.list_all_categroies()

        local v = view.new("blog-home.html", "layout.html")
        v.title = "Fong | " .. blogs[1]["category"] .. "分类"
        v.blogs = blogs
        v.categories = categories
        v.breadcrumbs = { 
            { category = "首页", uri = "/blog/" },
            { category = "博客", uri = "/blog/" },
            { category = blogs[1]["category"]}
        }
        v:render()
        return
    else
        ngx.exit(404)
    end

    ngx.exit(404)
end





return _M
