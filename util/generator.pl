#!/usr/bin/env perl
#
# This Perl script will generate all hightlighting style css files for Pandoc CodeBlock:
#   
#   ./$0
#

use strict;
use warnings;
use FindBin ();

my @styles = `pandoc --list-highlight-style`;

for my $style (@styles) {
    $style =~ s/^\s*|\s*$//g;

    my $cmd = "pandoc -s --highlight-style $style -f markdown $FindBin::Bin/codeblock.markdown";
    warn $cmd;

    my $out = `$cmd`;

    if ($out =~ /^.*(div\.sourceCode.*)\s*<\/style>/sm) {
        open my $css_file, ">$FindBin::Bin/$style.css" 
            or die "open file for writing error: $!";
        print $css_file $1;
        close $css_file;
    } else {
        die "parse pandoc output html file error!";
    }

}


