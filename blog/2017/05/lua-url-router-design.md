<!---
@title URL路由设计
@category 开发手册
@tags lua,programming,web
-->
# URL路由设计

本文是在阅读[router.lua](https://github.com/APItools/router.lua)源码时整理，一是为了帮助自己理解源码设计；二是为需要了解 Web URL 路由设计思路的同学提供参考。

若有错误请向我指出，谢谢。（邮箱：noodles.v6@gmail.com）

## 设计思路

思路：
1. 预先定义一套路由规则，预加载到内存中；
1. 拦截HTTP请求，进行规则匹配；

针对不同的Web平台架构，实现上可能有区别，但要做的事情主要是这两件。如：J2EE架构下，我们可以通过定义Servlet/Filter/Interceptor完成对HTTP请求的拦截。

这里我们基于Ngnix平台，针对开源项目[router.lua](https://github.com/APItools/router.lua)简单介绍下实现逻辑。

## router.lua

### 介绍

[router.lua](https://github.com/APItools/router.lua)是一个非常基础的路由，lua语言开发。

特性：

* 允许绑定 HTTP 请求到指定的函数。
* 支持参数化 URL，如：/app/services/:service_id
* 平台无关的，但是在 OpenResty 平台下测试的。

### 路由规则

假设路由支持如下 URL 规则：

```bash
GET  /hello
GET  /hello/*
GET  /hello/:name
POST /app/:id/comments
```

router.lua会把 path 的每个`子目录`抽象成`Json node`，从而构造如下的数据结构：

```json
{
  "POST": {
    "app": {
      "TOKEN": {
        "id": {
          "comments": {
            "LEAF": "<function: 0x08053d58>"
          }
        }
      }
    }
  },
  "GET": {
    "hello": {
      "WILDCARD": {
        "TOKEN": "",
        "LEAF": "<function: 0x0515bfa0>"
      },
      "TOKEN": {
        "name": {
          "LEAF": "<function: 0x08051dd8>"
        }
      },
      "LEAF": "<function: 0x08053180>"
    }
  }
}
```

lua代码实现：

```lua
local function match_one_path(node, path, f)
    for token in path:gmatch("[^/.]+") do
        if WILDCARD_BYTE == token:byte(1) then
            node['WILDCARD'] = {['LEAF'] = f, ['TOKEN'] = token:sub(2)}
            return
        end
        if COLON_BYTE == token:byte(1) then
            node['TOKEN'] = node['TOKEN'] or {}
            token = token:sub(2)
            node = node['TOKEN']
        end
        node[token] = node[token] or {}
        node = node[token]
    end
    node['LEAF'] = f
end
```

## 用户接口

先定义`路由规则`：

```lua
function Router:match(method, path, fun)
    if type(method) == 'string' then
        method = { [method] = {[path] = fun} }
    end

    for m, routes in pairs(method) do
        for p, f in pairs(routes) do
            if not self._tree[m] then self._tree[m] = {} end
            match_one_path(self._tree[m], p, f)
        end
    end
end
```

定义示例：

```lua
-- GET /hello
router:match('GET', '/hello', function(params)
    print("hello")
end)

-- GET /hello/:name
router:match('GET', '/hello/:name', function(params)
    print("hello" .. params.name)
end)

-- POST /app/:id/comments
router:match('POST', '/app/:id/comments', function(params)
    print("comment " .. params.comment .. ' created')
end)

```

路由定义好，我们该考虑如何使用规则了，即：对http请求，根据请求方法和请求uri匹配到规则，然后调用规则中的处理函数：

```lua
function Router:execute(method, path, ...)
    local f, params = self:resolve(method, path, ...)
    if not f then return nil, ('Could not resolve %s %s - %s'):format(tostring(method), tostring(path), tostring(params)) end
    return true, f(params)
end
```

调用示例：
```lua
router:execute('GET', '/hello')
router:execute('GET', '/hello/fonlang')
router:execute('POST', /app/4/comments', { comment = 'fascinating' })

```

## 感想

接口和数据结构是架构设计中极其重要的东西：
- 接口表达了我们想如何使用
- 数据结构表达了我们该如何实现

## 更多

* [Hacker News - A small router for Openresty](https://news.ycombinator.com/item?id=7647595)
* [Talk like a Googler: parts of a url](https://www.mattcutts.com/blog/seo-glossary-url-definitions/)
