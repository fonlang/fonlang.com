<!---
@title Linux inotify 接口工具
@category 开发手册
-->
# Linux inotify 接口工具

在用 `less` 调试网页样式时，不停修改 less 文件后，我都要执行`lessc style.less style.css` 生成新的 `style.css` 文件，麻烦。于是 Google 找到 [How to execute a command whenever a file changes?](https://superuser.com/questions/181517/how-to-execute-a-command-whenever-a-file-changes)，觉得 Linux 下的 inotify 可以探索下，于是根据《Linux/Unix系统编程手册》***第19章-监控文件事件*** 整理这篇文章。

## inotify 介绍

> 参考《Linux/Unix系统编程手册》第19章-监控文件事件

### 需求分析

* 需求：监控文件事件
* 输入：需监控的文件、需监控的事件
* 输出：发生的所有事件

### 关键步骤

1. 创建 `inotify` 实例（调用 `intofiy_init()`，返回文件描述符）；
1. 向 `inotify` 实例添加监控列表（调用 `inotify_add_watch()`，返回监控描述符）；
  - `inotify_rm_watch()` 为逆向操作，取消监控；
  - `inotify` 机制非递归，若要监控子目录，则需调用接口添加；
1. 通过 `inotify` 实例，读取事件通知（使用 `read()`）；
  - 每次 `read()` 调用成功后都会返回一个或多个 `struct inotify_event`；
1. 程序结束监控时，文件描述符会被关闭，相关资源也会被清除；

### inotify API

```
#include <sys/inofity.h>

int inotify_init(void);
int inotify_add_watch(int fd, const *pathname, uint32_t mask);
int inotify_rm_watch(int fd, uint32_t wd);
```

> inotify 实例及其内核数据结构

![inotify 实例及其内核数据结构](/images/20170603-inotify-struct.jpg)

### inotify 事件

[参见：Linux Programmer's Manual - inotify](http://man7.org/linux/man-pages/man7/inotify.7.html)

### 读取 inotify 事件

```
struct inotify_event {
    int       wd;       // Watch descriptor 监听描述符

    unit32_t  mask;     // 事件位值

    uint32_t  cookie;   // Cookie for related events (for rename())

    uint32_t  len;      // The len field counts all of the bytes in name,
                        // including the null
                        // bytes; the length of each inotify_event structure is thus
                        // sizeof(struct inotify_event)+len.

    char      name[];   // Present only when an event is returned for a file
                        // inside a watched directory
}
```
>包含3个inotify_event结构的输入缓冲区

![包含3个inotify_event结构的输入缓冲区](/images/20170603-inotify-event-buffer.jpg)

### 实例

[参见：linux inotify api example](https://gist.github.com/fonlang/eecebd98f6867351b92f340e87dd8f6e)

## 其他

* [inotify-tools](https://github.com/rvoicilas/inotify-tools)
* [entr](https://github.com/clibs/entr)
* [syncthing-inotify](https://github.com/syncthing/syncthing-inotify)

## 小结

Linux 里面充斥着各种数据结构和算法，精心地读懂研究它们，对我们的编码能力有极大的提升。
