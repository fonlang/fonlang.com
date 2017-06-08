#!/usr/bin/env perl

use Pandoc::Filter qw(pandoc_filter);
use Pandoc::Elements qw(Header CodeBlock Str);

pandoc_filter 
    CodeBlock => sub {
        #my ($e, $f, $m) = @_;
    
        #my $class = $e->keyvals->{class};
    
        #$e->keyvals( class => "$class numberLines") if defined $class;
    
        # require Data::Dumper;
        # 
        # open my $LOG, ">log.txt" or die "open file for writing error: $!";
        # print $LOG Dumper($e, $f, $m);
        # print $LOG Dumper($class);
        # close $LOG;
    
        return;
    },
    Header => sub {
        return unless $_->level <= 1; # keep
        return []; # replace
    },
;
