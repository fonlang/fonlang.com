#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--lang', '-a', default='text', help='the aim syntax language')
    parser.add_argument('--infile', '-i', type=argparse.FileType('r'), help='the input file just include code block')

    args = parser.parse_args(sys.argv[1:])

    lexer = get_lexer_by_name(args.lang, stripall=True)
    formatter = HtmlFormatter(linenos=True, cssclass="highlight")

    with args.infile:
        code = args.infile.read()

    result = highlight(code, lexer, formatter).encode('utf-8')
    print result
