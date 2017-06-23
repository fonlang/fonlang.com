<!---
@title What is Lex? What is Yacc? 译文
@category 开发手册
@tags translate,lex,yacc,compiler
-->
# What is Lex? What is Yacc? 译文

本文翻译自网页 [What is Lex? What is Yacc?](https://luv.asn.au/overheads/lex_yacc/) 。

## What is Lex? What is Yacc?

### What is Lex?

Lex 的正式名称为 Lexical Analyser 。

其主要工作是把 “输入流” 分割为 “多个可用单元”。

或者说，识别出文本文件中 “我们感兴趣的部分”。

举个例子，如果你正在为 C 语言编写编译器，像符号 { } ( ) ; 都是有意义的。单词 a 一般会是 keyword 或者 variable name 的一部分，a 自身是没有意义的，我们感兴趣的是整个单词。Spaces 和 newlines 也是没有意义的，除非出现在双引号里面 “like this”，否则完全可以忽略掉。

这些事情都是通过 Lexical Analyser 完成的。

### What is Yacc?

Yacc 被作为 “Parser” 著称。

其工作是分析 “输入流” 的结构，and operate of the “big picture”。

在此期间，它还会对 input 做语法检查。

再次考虑 C-compiler 例子。在 C 语言中，a word 可以是 function name 还是 variable，依赖于它后面是否跟的是 ( 或者 一个 = There should be exactly one } for each { in the program 。

YACC 代表 “Yet Another Compiler Compiler”。因为该种文本分析通常用啦编写 compiler 。

但是，就像我们看到的，它可以用于几乎适合任何基于文本的场景。

举例，像下面的 C 代码：

    {
        int int;
        int = 33;
        printf("int: %d", int);
    }

Lex 将会产生如下 “token” 序列：

    {
    int
    int
    ;
    int
    =
    33
    ;
    printf
    (
    "int: %d\n"
    ,
    int
    )
    ;
    }

注意：lexical analyser 已经发现了出现在双引号里面的 int ，并把其作为 literal string 的一部分。token int 被用作 keyword 或是 variable 是由 parser 决定的。parser 也可以拒绝把 int 作为 variable name 。parser 也保证了每个 statement 以 ; 结尾，并配有圆括号。

### Flex and Bison

Lex 和 Yacc 属于 BSD Unix 的组成部分。GNU 有自己的版本，叫做 Flex 和 Bison 。
