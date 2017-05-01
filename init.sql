-- create user fonlang with password 'qwer#1234'
-- create database fonlang_com;
-- grant all privileges on database fonlang_com to fonlang;

drop table if exists blogs cascade;

create table blogs (
    id serial primary key,
    uri varchar(128) unique not null,
    title text not null,
    category text not null,
    html_file text not null,
    summary_text text not null,
    creator varchar(32) not null,
    created timestamp with time zone not null,
    modifier varchar(32) not null,
    modified timestamp with time zone not null,
    changes int not null
);

drop table if exists category cascade;

create table category (
    id serial primary key,
    category text unique not null,
    uri text not null
);

insert into category (category, uri) values 
    ('开发手册', '/blog/category/developer'),
    ('抗癌日志', '/blog/category/cancer'),
    ('有趣的事', '/blog/category/fun'),
    ('随笔', '/blog/category/notes'),
    ('待办事项', '/blog/category/todo');

\copy blogs (uri, title, category, html_file, summary_text, creator, created, modifier, modified, changes) from 'blogs.tsv'
