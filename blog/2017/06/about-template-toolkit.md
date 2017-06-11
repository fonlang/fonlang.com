<!---
@title Perl 关于 Template::Toolkit 
@category 开发手册
-->
# Perl 关于 Template::Toolkit

[http://www.template-toolkit.org/about.html](http://www.template-toolkit.org/about.html)的非官方译文。

## 介绍

Template::Toolkit 是免费开源的 template 处理系统，速度快，灵活高度可扩展，几乎可以运行在所有人类已知的现代操作系统上。它使用 Perl 语言开发，为了性能考虑，其中一些关键的地方使用 C 语言编写。但在使用 Template::Toolkit 时，您不需要了解任何有关 Perl 和 C 的知识。

Template::Toolkit 非常适合（但不限于）构建静态或动态 Web 内容，并提供了各种模块和工具简化构建过程。它成熟，健壮，可靠，且高度文档化。

## 特性

Template::Toolkit 主要特性概述。

* 快速，强大，可扩展的 template 处理系统。
* 强大的 presentation 语言，支持所有标准 template 指令，如 variable substitution, includes, conditional, loops。
* 还提供了如 output filter，exception handling，macro definition，plugin，definitionof template metadata 等特性。
* 支持复杂数据结构，如 hashes，lists，objects，subroutine reference。
* 提供 content, user interface elemenets, application code 和 data 之间的清晰分离。
* Designer-centric front end hides underlying complexity behind simple variable access。
* 以程序员为中心的后端，允许使用 Perl 构建业务逻辑和数据结构。
* 为了最大化性能，Templates 会被编译成 Perl 代码。被编译的 templates 会被缓存，也可以以编译后的形式存储到磁盘，实现缓存持久化。
* 非常适合在线动态网页内容的生成（例如 Apache / mod_perl）。
* 还可以从源模板生成静态网页，如 HTML，POD， LaTeX，PostScript， plain text。
* 文档全面，包括教程和参考手册。
* 免费开源。

## 例子

下面的例子让您了解 Template::Toolkit 可以做什么。有关 Template::Toolkit 的具体使用，请参阅 [Template::Manual](http://www.template-toolkit.org/docs/manual/index.html)。

### Templates and Variables

从一个不是模板的模板开始。

```
Hello World!
```
为什么说它是“不是模板的模板”？因为：

* templates 就是一个常规的文本文件。
* 不包含在指令标签里的内容，都会原样输出。

开始添加一些 tags ，让它看起来更像一个 template 。[Tags](http://www.template-toolkit.org/docs/manual/Syntax.html) 存在于 [% 和 %] 之间，包含 [Directive](http://www.template-toolkit.org/docs/manual/Directives.html) 告诉 Template::Toolkit 执行一些动作。
下一个例子：

```html
[% INCLUDE header title="My First Example" %]
<p>
    Hello World!
</p>
[% INCLUDE footer copyright="2007 Arthur Dent" %]
```
这个例子演示了第二个重要的概念：我们可以创建可复用的 template 组件，像 header 和 footer 可以使用 INCLUDE directive 被加载到其他的 templates。它们看起来类似：

> header

```html
<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.01 Strict//EN">
<html>
  <head>
    <title>[% title %]</title>
  </head>
  <body>
    <div id="header'>
      <a href="/index.html" class="logo" alt="Home Page"></a>
      <h1 class="headline">[% title %]</h1>
    </div>
```

> footer

```html
    <div id="footer">
      <div id="copyright">
        &copy;  % copyright %]
      </div>
    </div>
  </body>
</html>
```

注意 `[% title %]` 和 `[% copyright %]` 出现的位置。当 INCLUDE 了 header 和 footer 组件后，我们就可以给 title 和 copyright 提供 value 了。The Template::Toolkit is very flexible about where and how you define variables。

这个例子唯一的问题是我们把页面布局放在了两个文件里，如果只有一个 template 文件，会更容易维护。就像这样：

> layout

```html
<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.01 Strict//EN">
<html>
  <head>
    <title>[% title %]</title>
  </head>
  <body>
    <div id="header'>
      <a href="/index.html" class="logo" alt="Home Page"></a>
      <h1 class="headline">[% title %]</h1>
    </div>

    [% content %]

    <div id="footer">
      <div id="copyright">
        &copy;  % copyright %]
      </div>
    </div>
  </body>
</html>
```

现在我们可以使用 WRAPPER directive 把 layout template 应用到 “Hello World” template。

```html
[% WRAPPER layout
    title       = "My First Example"
    copyright   = "2007 Arthur Dent"
%]
<p>
  Hello World!
<p>
[% END %]
```

Template::Toolkit 会先处理 WRAPPER 和 END 之间的内容，存放到 content 变量中，连同 title 和 copyright 变量传递给 layout template。你也能够像如下这样书写该例子：

```html
[% INCLUDE layut
    title       = "My First Example"
    copyright   = "2007 Arthur Dent"
    content     = "<p>\n  Hello World!\n</p>"
%]
```

### Complex Data

Template::Toolkit 中您可以把 data 定义在 template 中，或者 Perl 程序返回，或者通过 plugin module 从外部源读入（如 database，xml 文件等）。您可以定义 complex data types，如 lists，hash arrays， objects 甚至 subroutines。

Complex data structures 的元素访问使用 dot operator，无论它们具有何种基础数据类型（underlying data type）。比如，可以通过 person.email 和 person.name 从 person hash array 中获取 email 和 name ，也可以是调用 person object 中 email 和 name 方法。Template::Toolkit 会自动识别被访问的数据类型。

> 示例：访问 hash table

```html
[% person = {
     name   = "Tom"
     email  = "tom@tt2.org"
   }
%]
[% person.name %]
[% person.email %]
```

> 示例：访问 list

```html
[% people = ['Tom', 'Dick', 'Larry'] %]
[% people.0 %]
[% people.1 %]
[% people.2 %]
```

Template::Toolkit 提供了大量的 [Virtual Methods](http://www.template-toolkit.org/docs/manual/VMethods.html)，可以查看和操作数据。如你可以使用 .size 获取 list 中的 items 数目，使用 .join 将 items 拼接起来。

```html
[% people.size %]
[% people.join(', ') %]
```

### Loops and Conditions

FOREACH directive 会重复指定的 template block 。下面例子使用的是 hash arrays。

```html
[% people = [
     { name = 'Tom',     email = 'tom@tt2.org'   }
     { name = 'Dick',    email = 'dick@tt2.org'  }
     { name = 'Larry',   email = 'larry@tt2.org' }
   ]
%]
<ul>
[% FOREACH person IN people %]
  <li><a href="mailto:[% person.email %]">[% person.name %]</a></li>
[% END %]
</ul>
```

在 FOREACH 循环里，可以使用 loop 变量 test certain condition 。如 loop.first 判断是否是循环里的 first item ，loop.last 判断是否是 last item 。

在 loop 中使用 [IF](http://www.template-toolkit.org/docs/manual/Directives.html#section_IF) directive ，可以完成逻辑判断。也可以使用 loop.count 判断循环当前的位置。

```html
[% FOREACH person IN people %]
[%      IF loop.first %]
<table>
  <tr>
    <th>Rank</th>
    <th>Name</th>
    <th>Email</th>
  </tr>
[%      END %]
  <tr>
    <td>[% loop.count %]</td>
    <td>[% person.name %]</td>
    <td>[% person.email %]</td>
  </tr>
[%      IF loop.last %]
</table>
[%     END %]
[% END %]
```

IF statements 还可以联合 ELSIF 和 ELSE 使用。

```html
[% IF age < 18 %]
You are too young.
[% ELSIF age > 65 %]
You are too old.
[% ELSE %]
Welcome!
[% END %]
```

### Filters and Plugins

Template::Toolkit 提供了大量的 text [filters](http://www.template-toolkit.org/docs/manual/Filters.html) ，用来后置处理 template content 。upper filter 能将所有文本转换为大写。

```html
[% FILTER upper %]
Hello World!    # HELLO WORLD!
[% END %]
```

[Plugins](http://www.template-toolkit.org/docs/manual/Plugins.html) 是用 Perl 编写的扩展模块，允许你将任何额外的功能集成到 Template::Toolkit 中。举个例子，[CGI](http://www.template-toolkit.org/docs/modules/Template/Plugin/CGI.html) plugin 可以访问 CGI 模块，从而完成 CGI 参数，cookies 等的访问。

```html
[% USE CGI %]
[% name = CGI.param('name') or 'World' %']
Hello [% name %]
```

再如，使用 [DBI](http://search.cpan.org/search?mode=module&query=Template%3A%3ADBI) plugin 完成查询数据库的功能。

```html
[% USE DBI( database = 'dbi:mysql:dbname',
            username = 'guest',
            password = 'topsecret' )
%]
<ul>
[% FOREACH customer IN DBI.query('SELECT * FROM customers') %]
  <li>[% customer.name %]</li>
[% END %]
</ul>
```
