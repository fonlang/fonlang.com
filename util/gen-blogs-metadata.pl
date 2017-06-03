#!/usr/bin/env perl

use v5.010;
use strict;
use warnings;
use Data::Dumper;
use Encode;
use HTML::Strip;

my $hs = HTML::Strip->new();

my $dirname = "templates/blog";
if (!-d $dirname) {
    die "directory $dirname does not exist yet. maybe you forgot to make?\n";
}

my @rows;
my $n = handle_dir($dirname, \@rows);

print "$n html files handled into \@rows.\n";

my $outfile = "posts.tsv";
$n = dump_rows(\@rows, $outfile);
print "$n rows dumped to $outfile.\n";
$hs->eof;

sub handle_dir {
    my ($dirname, $rows) = @_;

    opendir my $dir, $dirname
        or die "cannot open $dirname for reading: $!\n";

    while (my $entity = readdir $dir) {
        #warn $entity;
        if ($entity eq '.' || $entity eq '..') {
            next;
        }

        my $fname = "$dirname/$entity";

        if (-d $fname) {
            handle_dir($fname, $rows);
            next;
        }

        if (-f $fname && $entity =~ /(.+)\.html$/) {
            my $name = $1;
            #warn $name;
            my $rec = parse_file($name, $fname);
            push @$rows, $rec;
            next;
        }
    }

    close $dir;

    return scalar @$rows;
}

sub parse_file {
    my ($name, $file) = @_;

    open my $in, "<:encoding(UTF-8)", $file
        or die "cannot open $file for reading: $!\n";

    my $html = do { local $/; <$in> };
    close $in;

    my %attr;
    if ($html =~ s/ \A <!--- \s* (.*?) --> (?: \n | $ ) //xsm) {
        my $meta = $1;
        %attr = map { if (/\@(\S+)\s+(.*)/) { ($1, $2) } else { () } }
                        split /\n/, $meta;
    } else {
        die "$file: meta data not edit.\n";
    }

    if ($html =~ /\A <p>(.*)<\/p> (?: \n | $ ) /xm) {
        my $clean_text = $hs->parse( $1 );
        $attr{summary_text} = $clean_text;
    } else {
        $attr{summary_text} = ' ';
    }

    if (!defined $attr{category}) {
        die "$file: category not defined!\n";
    }

    if ($attr{modifier} && !$attr{modified} && $attr{created}) {
        $attr{modified} = $attr{created};
    }

    my (%missing_keys);
    for my $key (qw/ creator created modifier modified changes /) {
        if (!$attr{$key}) {
            warn "$file: key $key not found. parsing git meta...\n";
            $missing_keys{$key} = 1;
        }
    }

    if ($file =~ /templates\/blog\/\d+\/\d+\/([\w-]+)\.html/) {
        $attr{uri} = "/blog/$1";
    } else {
        die "invalid blog file";
        #$uri =~ s/(?<!^\/)/\//; # add prefix "/"
        #$uri;
    }

    $attr{html_file} = do {
        my $html_file = $file;
        $html_file =~ s/templates\///;
        $html_file;
    };

    if (%missing_keys) {
        my $md_file = do {
          my $md_file = $file;
          $md_file =~ s/^templates\///;
          $md_file =~ s/\.html/\.md/;
          $md_file;
        };

        my $cmd = "git log -- $md_file";

        open my $in, "$cmd|"
            or die "cannot open pipe to command $cmd: $!\n";

        my ($changes, $modifier, $creator, $modified, $created);
        while (<$in>) {
            if (/^commit /) {
                $changes++;
                next;
            }

            if (/^Author:\s*([^<]*)/) {
                if (!defined $modifier) {
                    $modifier = $1;
                    $modifier =~ s/^\s+|\s+$//g;
                }

                $creator = $1;
                next;
            }

            if (/^Date:\s*(.*)/) {
                if (!defined $modified) {
                    $modified = $1;
                    $modified =~ s/^\s+|\s+$//g;
                }

                $created = $1;
            }
        }

        close $in;

        if (defined $creator) {
            $creator =~ s/^\s+|\s+$//g;
            if ($missing_keys{creator}) {
                $attr{creator} = $creator;
            }
        }

        if (defined $created) {
            $created =~ s/^\s+|\s+$//g;
            if ($missing_keys{created}) {
                $attr{created} = $created;
            }
        }

        if ($missing_keys{modified}) {
            $attr{modified} = $modified;
        }

        if ($missing_keys{modifier}) {
            $attr{modifier} = $modifier;
        }

        if ($missing_keys{changes}) {
            $attr{changes} = $changes;
        }

    }

    return \%attr;
}

sub dump_rows {
    my ($rows, $file) = @_;

    open my $out, ">:encoding(UTF-8)", $file
        or die "cannot open $file for writing: $!\n";

    for my $r (@$rows) {
        print $out quote_value($r, 'uri'), "\t",
            quote_value($r, 'title'), "\t",
            quote_value($r, 'category'), "\t",
            quote_value($r, 'html_file'), "\t",
            quote_value($r, 'summary_text'), "\t",
            quote_value($r, 'creator'), "\t",
            quote_value($r, 'created'), "\t",
            quote_value($r, 'modifier'), "\t",
            quote_value($r, 'modified'), "\t",
            quote_value($r, 'changes'),
            "\n";
    }

    close $out;

    return scalar @$rows;
}

sub quote_value {
    my ($r, $k) = @_;

    my $s = $r->{$k};
    if (!$s) {
        die "$r->{uri}.md: meta data \"$k\" not defined.\n";
    }

    $s =~ s/\\/\\\\/g;
    $s =~ s/\x{08}/\\b/g;
    $s =~ s/\f/\\f/g;
    $s =~ s/\n/\\n/g;
    $s =~ s/\r/\\r/g;
    $s =~ s/\t/\\t/g;
    $s =~ s/\v/\\v/g;
    $s;
}
