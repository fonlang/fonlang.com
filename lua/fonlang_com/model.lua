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

    -- print(inspect(res))

    return res
end

-- 获取指定post的meta数据
function _M.get_post_by_url(url)
    local res = query_db(
        "select b.url, title, category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where b.category_name = c.name  and b.url = '" .. url .. "'"
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no post found: url=" .. url)
        return ''
    end

    -- print ("JSON: ", cjson.encode(res))
    
    return res[1]
end

-- 获取最近发布的post列表
function _M.list_latest_created_posts()
    local res = query_db(
        "select b.url, title, category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where b.category_name = c.name "
        .. "order by created desc limit 10"
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no post found")
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))
   
    return res
end

-- 获取全部博客
function _M.list_all_posts()
    local res = query_db(
        "select b.url, title, category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where b.category_name = c.name "
        .. "order by b.created desc "
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no posts found")
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))

    return res
end

--  
function _M.list_all_archive()
    local res = query_db(
        "select url, title, to_char(created, 'yyyy') as year, to_char(modified, 'MM-dd') as monday "
        .. "from posts "
        .. "order by created desc "
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no archive found")
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))

    return res
end
-- 获取指定分类下的博客
function _M.list_posts_by_category_url(url)
    local res = query_db(
        "select b.url, title, b.category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where c.url = '" .. url .. "' and b.category_name = c.name "
        .. "order by b.created desc "
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no posts found : category.url=" .. url)
        return ngx.exit(500)
    end

    -- print ("JSON: ", cjson.encode(res))
   
    return res
end

-- 获取所有的分类
function _M.list_all_categroies()
    local res = query_db(
        "select c.name, c.url, count(1) number from posts b, category c "
        .. "where b.category_name = c.name "
        .. "group by c.name, c.url"
    )

    -- print ("JSON: ", inspect(res));

    if #res == 0 then
        ngx.log(ngx.ERR, "no category found")
        return ngx.exit(500)
    end

    return res 
end


return _M
