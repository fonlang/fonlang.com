local _M = {}

local pgmoon = require "pgmoon"
local cjson = require "cjson"
local inspect = require "inspect"
local quote_sql_str = ndk.set_var.set_quote_pgsql_str

local db_spec = {
    host = "127.0.0.1",
    port = "5432",
    database = "fonlang_com",
    user = "fonlang",
    password = "qwer#1234"
}

local function query_db(query)
    local pg = pgmoon.new(db_spec)

    print("sql query: ", query)

    local ok, err

    for i = 1, 3 do
        ok, err = pg:connect()
        if not ok then
            ngx.log(ngx.ERR, "failed to connect to database: ", err)
            ngx.sleep(0.1)
        else
            break
        end
    end

    if not ok then
        ngx.log(ngx.ERR, "fatal response due to query failures")
        return ngx.exit(500)
    end

    local res
    for i = 1, 2 do
        res, err = pg:query(query)
        if not res then
            ngx.log(ngx.ERR, "failed to send query: ", err)

            ngx.sleep(0.1)

            ok, err = pg:connect()
            if not ok then
                ngx.log(ngx.ERR, "failed to connect to database: ", err)
                break
            end
        else
            break
        end
    end

    if not res then
        ngx.log(ngx.ERR, "fatal response due to query failures")
        return ngx.exit(500)
    end

    local ok, err = pg:keepalive(0, 5)
    if not ok then
        ngx.log(ngx.ERR, "failed to keep alive: ", err)
    end

    return res
end

-- 获取指定blog的meta数据
function _M.get_blog_by_uri(uri)
    local res = query_db(
        "select url, title, category, modifier, to_char(created, 'dd Mon yyyy') as created, "
        .. "to_char(modified, 'dd Mon yyyy') as modified, "
        .. "html_file, summary_text from posts "
        .. "where url = '" .. uri .. "'"
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no blog found: uri=" .. uri)
        return ''
    end

    -- print ("JSON: ", cjson.encode(res))
    
    return res[1]
end

-- 获取最近发布的blog列表
function _M.list_latest_created_blogs()
    local res = query_db(
        "select url, title, category, modifier, to_char(created, 'dd Mon yyyy') as created, "
        .. "to_char(modified, 'dd Mon yyyy') as modified, "
        .. "html_file, summary_text from posts "
        .. "order by created desc limit 10"
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no blog found")
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))
   
    return res
end

-- 获取全部博客
function _M.list_all_blogs()
    local res = query_db(
        "select b.url, title, b.category, modifier, to_char(created, 'dd Mon yyyy') as created, "
        .. "to_char(modified, 'dd Mon yyyy') as modified, "
        .. "html_file, summary_text from posts b "
        .. "order by b.created desc "
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no blogs found")
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))

    return res
end
-- 获取指定分类下的博客
function _M.list_blogs_by_category_uri(uri)
    local res = query_db(
        "select b.url, title, b.category, modifier, to_char(created, 'dd Mon yyyy') as created, "
        .. "to_char(modified, 'dd Mon yyyy') as modified, "
        .. "html_file, summary_text from posts b, category c "
        .. "where c.url = '" .. uri .. "' and b.category = c.name "
        .. "order by b.created desc "
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no blogs found : category.uri=" .. uri)
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))
   
    return res
end

-- 获取所有的分类
function _M.list_all_categroies()
    local res = query_db(
        "select c.name, c.url, count(1) count from posts b, category c "
        .. "where b.category = c.name "
        .. "group by c.name, c.url"
    )

    -- print ("JSON: ", inspect(res));

    if #res == 0 then
        ngx.log(ngx.ERR, "no category found")
        return ngx.exit(500)
    end

    local categories = {
        { category = "全部文章", uri = "/blog/category/", count = 0 },
    }

    for _, v in ipairs(res) do
        table.insert(categories, v)
        categories[1]["count"] = categories[1]["count"] + v["count"]
    end

    -- print ("JSON: ", inspect(categories));

    return categories
end


return _M
