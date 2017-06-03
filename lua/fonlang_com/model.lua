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


local function wrap_page_res(list, page_num, page_size, total)
    local size = #list
    local pages = 0
    local start_row = -1
    local end_row = -1
    local is_first_page = false
    local is_last_page = false
    local has_prev_page = false
    local has_next_page = false
    local prev_page = -1
    local next_page = -1
    local navigate_pages = 4
    local navigate_page_nums = {}
    local navigate_first_page = -1
    local navigate_last_page = -1

    if page_size > 0 then
        pages = math.floor(total / page_size + ((total % page_size == 0 and 0) or 1))
    end

    start_row = (page_num > 0 and (page_num - 1) * page_size) or 0
    end_row = start_row + page_size * ((page_num > 0 and 1) or 0)

    if pages <= navigate_pages then
        for i = 1, pages do
            navigate_page_nums[i] = i
        end
    else
        local start_num = page_num - navigate_pages / 2
        local end_num = page_num + navigate_pages / 2

        if start_num < 1 then
            start_num = 1
            for i = 1, navigate_pages do
                navigate_page_nums[i] = start_num
                start_num = start_num + 1
            end
        elseif end_num > pages then
            end_num = pages
            for i = navigate_pages, 1, -1 do
                navigate_page_nums[i] = end_num
                end_num = end_num - 1
            end
        else
            for i = 1, navigate_pages do
                navigate_page_nums[i] = start_num
                start_num = start_num + 1
            end
        end
    end

    if navigate_page_nums ~= nil and #navigate_page_nums > 0 then
        navigate_first_page = navigate_page_nums[1]
        navigate_last_page = navigate_page_nums[navigate_page_nums]

        if page_num > 1 then
            pre_page = page_num - 1
        end

        if page_num < pages then
            next_page = page_num + 1
        end
    end

    is_first_page = page_num == 1
    is_last_page = page_num == pages or pages == 0
    has_prev_page = page_num > 1
    has_next_page = page_num < pages

    return {
        list = list,
        page_num = page_num,
        page_size = page_size,
        size = size,
        start_row = start_row,
        end_row = end_row,
        total = total,
        pages = pages,
        prev_page = prev_page,
        next_page = next_page,
        is_first_page = is_first_page,
        is_last_page = is_last_page,
        has_prev_page = has_prev_page,
        has_next_page = has_next_page,
        navigate_pages = navigate_pages,
        navigate_first_page = navigate_first_page,
        navigate_last_page = navigate_last_page,
        navigate_page_nums = navigate_page_nums,
    }
end

-- 分页查询
local function page_query_db(query, page_num, page_size)
    local count_res = query_db("select count(*) from (" .. query .. ") t")
    local total = count_res[1].count

    if total == 0 then
        return wrap_page_res({}, page_num, page_size, total)
    end

    local limit = page_size
    local offset = (page_num - 1) * page_size
    local res = query_db(
        "select * from (" .. query .. ") t"
        .. " limit " .. limit
        .. " offset " .. offset
    )

    return wrap_page_res(res, page_num, page_size, total)
end

------------------------------------------------------------------ Interfaces

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
function _M.list_latest_created_posts(page_num, page_size)
    local res = page_query_db(
        "select b.url, title, category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where b.category_name = c.name "
        .. "order by created desc",
        page_num,
        page_size
    )

    if #res['list'] == 0 then
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

function _M.list_all_archive()
    local res = query_db(
        "select url, title, to_char(created, 'yyyy') as year, to_char(created, 'MM-dd') as monday "
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
function _M.list_posts_by_category_url(url, page_num, page_size)
    local res = page_query_db(
        "select b.url, title, b.category_name, c.url as category_url, modifier, html_file, summary_text, "
        .. "to_char(created, 'yyyy-MM-dd') as created, to_char(modified, 'yyyy-MM-dd') as modified "
        .. "from posts b, category c "
        .. "where c.url = '" .. url .. "' and b.category_name = c.name "
        .. "order by b.created desc ",
        page_num,
        page_size
    )

    if #res['list'] == 0 then
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

function _M.get_category_by_url(url)
    local res = query_db(
        "select * from category where url='" .. url .. "'"
    )

    if #res == 0 then
        ngx.log(ngx.ERR, "no category found")
        return ngx.exit(500)
    end

    return res[1]
end

return _M
