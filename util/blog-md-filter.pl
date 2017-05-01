#!/usr/bin/env perl

use strict;
use warnings;
use Pandoc::Filter;
use Pandoc::Elements qw(Str Header);

my $incomment = 0;

pandoc_filter 
    Header => sub {
        return unless $_->level <= 1; # keep
        return []; # replace
    },
;
 
