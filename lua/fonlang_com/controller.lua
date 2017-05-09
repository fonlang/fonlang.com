local _M = {}

local view = require "fonlang_com.view"
local model = require "fonlang_com.model"
local theme = require "fonlang_com.config"
local inspect = require "inspect"
local cjson = require "cjson"

local ngx_var = ngx.var
local resp_header = ngx.header


local function get_category_uri(category, categories) 
    for _, v in ipairs(categories) do 
        if v["category"] == category then
            -- print (v["category"] .. " ==> " .. category .. " ==> " .. v["uri"])
            return v["uri"]
        end
    end

    return ''
end


-- /
function _M.index(params)
    resp_header["Cache-Control"] = "max-age=3600"
    return ngx.redirect("/blog/", 302)
end

-- m{/blog/?}
function _M.blog_home(params)
    local blogs = model.list_latest_created_blogs()
    local categories = model.list_all_categroies()

    for _, post in blogs do
        post['categories'] = categories
    end

    local v = view.new("index.html")
    v.title = "Fong | 与癌症斗争着的编码者"
    v.blogs = blogs
    v.categories = categories
    v.breadcrumbs = { 
        { category = "首页", uri = "/blog/" },
        { category = "博客", uri = "/blog/" },
        { category = "全部文章" }
    }
    v.page = {
        total = 10,
        prev = 1,
        prev_link = "/",
        next = 1,
        next_link = "/",
        posts = blogs
    }
    v.theme = theme
    v:render()
end

-- m{/blog/:blog_entry}
function _M.blog_entry(params) 
    local uri = ngx_var.uri

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

-- m{/blog/category/:category}
function _M.blog_list_by_category(params)
    local uri = ngx_var.uri

    local blogs = {}
    if not params.category then
        blogs = model.list_all_blogs()
    else
        blogs = model.list_blogs_by_category_uri(uri)
    end

    local categories = model.list_all_categroies()

    local v = view.new("blog-home.html", "layout.html")
    v.title = "Fong | " .. blogs[1]["category"] .. "分类"
    v.blogs = blogs
    v.categories = categories
    
    if not params.category then
        v.breadcrumbs = { 
            { category = "首页", uri = "/blog/" },
            { category = "博客", uri = "/blog/" },
        }
    else
        v.breadcrumbs = { 
            { category = "首页", uri = "/blog/" },
            { category = "博客", uri = "/blog/" },
            { category = blogs[1]["category"]}
        }
    end

    v:render()
end

return _M
