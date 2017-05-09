local _M = {
    -- search
    search = {
        enable = true,
        service = "hexo", -- google/hexo/algolia/azure/baidu
        -- google
        -- google_api_key = ,
        -- google_engine_id = ,
        -- algolia
        -- algolia_app_id = ,
        -- algolia_api_key = ,
        -- algolia_index_name = ,
        -- azure
        -- azure_service_name = ,
        -- azure_index_name = ,
        -- azure_query_key = ,
        -- baidu
        -- baidu_api_id = ,
    },

    -- friends link
    links = {
        { name = "ClassicOldSong", url = "https://ccoooss.com" },
        { name = "Frantic1048", url = "https://frantic1048.logdown.com/" },
        { name = "Hclmaster", url = "https://hclmaster.github.io/" },
    },

    -- navigation menu
    menu = {
        { name = "Home", slug = "home", url = "/blog/" },
        { name = "Archives", slug = "archives", url = "/blog/archives" },
        { name = "About", slug = "about", url = "/blog/about" },
    },

    -- widgets
    widgets = {
        "about",
        "links",
        "categories",
        "tagcloud"
    },

    -- social
    social = {
        { slug = "github", url = "https://github.com/fonlang" },
        { slug = "sina", url = "http://fonglang.com" },
        { slug = "rss", url = "/atom.xml" }
    }
}

return _M
