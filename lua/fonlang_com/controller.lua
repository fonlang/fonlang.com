local _M = {}

local view = require "fonlang_com.view"
local model = require "fonlang_com.model"
local theme = require "fonlang_com.config"
local inspect = require "inspect"
local cjson = require "cjson"

local ngx_var = ngx.var
local resp_header = ngx.header


function _M.index(params)
    resp_header["Cache-Control"] = "max-age=3600"
    return ngx.redirect("/blog/", 302)
end

function _M.blog(params)
    local posts = model.list_latest_created_posts()
    local categories = model.list_all_categroies()

    local v = view.new("blog.html")
    v.title = "Fong | 与癌症斗争着的编码者"
    v.categories = categories
    v.theme = theme
    v.page = {
        total = 10,
        prev = 1,
        prev_link = "/blog/",
        next = 1,
        next_link = "/blog/",
        posts = posts
    }
    v:render()
end

function _M.blog_article(params)
    local uri = ngx_var.uri

    local post = model.get_post_by_url(uri)
    if post then
        local categories = model.list_all_categroies()

        local v = view.new("blog-article.html")
        v.title = "Fong | " .. post['title']
        v.categories = categories
        v.theme = theme
        v.post = post
        v:render()
        return
    else
        ngx.exit(500)
    end
end

function _M.blog_category(params)
    local uri = ngx_var.uri

    if not params.category then
        ngx.exit(404)
    end

    local posts = model.list_posts_by_category_url(uri)
    local categories = model.list_all_categroies()

    local v = view.new("blog-category.html")
    v.title = "Fong | 与癌症斗争着的编码者"
    v.categories = categories
    v.theme = theme
    v.page = {
        total = 10,
        prev = 1,
        prev_link = "/blog/",
        next = 1,
        next_link = "/blog/",
        posts = posts
    }
    v:render()
end

function _M.blog_archive(params)
    local uri = ngx_var.uri

    local archive = model.list_all_archive()
    local categories = model.list_all_categroies()

    local v = view.new("blog-archive.html")
    v.title = "Fong | 与癌症斗争着的编码者"
    v.categories = categories
    v.theme = theme
    v.page = {
        totle = 10,
        prev = 1,
        prev_link = "/blog/archive/",
        next = 1,
        prev_link = "/blog/archive/",
        archive = archive
    }
    v:render()
end

return _M
