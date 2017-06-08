<!---
@title  PostgreSQL数据库及入门
@category 开发手册  
-->
# PostgreSQL数据库及入门

本教程是Fong在开发自己的[博客网站](http://www.fonlang.com/blog/)时整理的，由于网站使用的AWS的Ubuntu套件，
所以，这里暂时只列举Ubuntu下的安装。

## Ubuntu下安装

### 安装客户端
```bash
sudo apt-get install postgresql-client
```

### 安装服务器
```bash
sudo apt-get install postgresql
```
安装过程中，你会看到如下输出（每次安装过程你都应该关注这里输出，它给出了安装的一些关键信息）：

```bash
Setting up libxslt1.1:amd64 (1.1.28-2.1ubuntu0.1) ...
Setting up ssl-cert (1.0.37) ...
Setting up postgresql-common (173) ...
Adding user postgres to group ssl-cert

Creating config file /etc/postgresql-common/createcluster.conf with new version

Creating config file /etc/logrotate.d/postgresql-common with new version
Building PostgreSQL dictionaries from installed myspell/hunspell packages...
Removing obsolete dictionary files:
...
Setting up postgresql-9.5 (9.5.6-0ubuntu0.16.04) ...
Creating new cluster 9.5/main ...
  config /etc/postgresql/9.5/main
  data   /var/lib/postgresql/9.5/main
  locale en_US.UTF-8
  socket /var/run/postgresql
  port   5432
update-alternatives: using /usr/share/postgresql/9.5/man/man1/postmaster.1.gz to provide /usr/share/man/man1/postmaster.1.gz (postmaster.1.gz) in auto mode
Setting up postgresql (9.5+173) ...
Setting up postgresql-contrib-9.5 (9.5.6-0ubuntu0.16.04) ...
Setting up sysstat (11.2.0-1ubuntu0.1) ...

Creating config file /etc/default/sysstat with new version
update-alternatives: using /usr/bin/sar.sysstat to provide /usr/bin/sar (sar) in auto mode
Processing triggers for libc-bin (2.23-0ubuntu7) ...
Processing triggers for systemd (229-4ubuntu16) ...
Processing triggers for ureadahead (0.100.0-19) ...
```

### 新建数据库用户

初次安装后，默认生成一个名为 postgres 数据库及名为 postgres 的数据库用户，同时还生成名为 postgres 的 Linux 系统用户，我们要通过这个 postgres 用户创建其他的用户及数据库。

创建系统用户 fonlang：
```bash
ubuntu@localhost:~$ sudo adduser fonlang
Adding user `fonlang' ...
Adding new group `fonlang' (1001) ...
Adding new user `fonlang' (1001) with group `fonlang' ...
Creating home directory `/home/fonlang' ...
Copying files from `/etc/skel' ...
```

切换到 postgres 用户，键入 psql 登录到数据库控制台：
```bash
ubuntu@localhost:~$ sudo su - postgres
postgres@localhost:~$ psql
psql (9.5.6)
Type "help" for help.

postgres=#
```

当然你也可以 `psql -h127.0.0.1 -Upostgres -p'yourpassword'`， 前提是你要知道 postgres 数据库用户的密码哦！

使用`\passwrd`命令修改 postgres 数据库用户的密码：
```bash
postgres=# \password
Enter new password:
Enter it again:
postgres=#
```

使用`CREATE USER`命令新建数据库用户：
```bash
postgres=# CREATE USER fonlang WITH PASSWORD 'balabalab';
CREATE ROLE
```

### 允许远程访问

打开配置文件 `/etc/postgresql/9.5/main/postgresql.conf`，修改 `listen_addresses`：
```bash
vi /etc/postgresql/9.5/main/postgresql.conf
listen_addresses = "*"
```

打开 `/etc/postgresql/9.3/main/pg_hba.conf`, 添加下面行以保证远程连接的任何用户可访问：
```bash
host all all 192.169.3.0/24  md5

```

### 创建数据库

使用 `CREATE DATABASE` 命令新建数据库：
```bash
postgres=# CREATE DATABASE fonlang_com OWNER fonlang;
CREATE DATABASE
postgres=#
```

赋权限给指定用户（一定要所有权限都赋予用户，否则用户只能登录控制台，但没有任何数据库的权限）：
```bash
postgres=# GRANT ALL PRIVILEGES ON DATABASE fonlang_com to fonlang;
GRANT
```

退出
```bash
postgres=# \q

```

### 登录数据库

ubuntu系统用户存在，但数据库用户不存在：
```bash
ubuntu@localhost:~$ psql
psql: FATAL:  role "ubuntu" does not exist
```

fonlang登录：
```bash
psql -U fonlang -d fonlang_com -h 127.0.0.1 -p 5432
```

## 更多

* [PostgreSQL官方Wiki](https://wiki.postgresql.org/wiki/Main_Page)
* [Using PostgreSQL on Debian and Ubuntu](http://www.stuartellis.name/articles/postgresql-setup/)
* [阮一峰 - PostgreSQL新手入门](http://www.ruanyifeng.com/blog/2013/12/getting_started_with_postgresql.html)
