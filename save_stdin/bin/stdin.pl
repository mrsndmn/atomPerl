#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Data::Dumper;

my ($needHelp, $fileName);
my ($length, $count) = qw(0 0);

GetOptions (
    "file=s" => \$fileName,
    'help|?' => \$needHelp
) or pod2usage(1);

 pod2usage(1) if ($needHelp || !defined $fileName);

# die "No such file ${fileName}" if ( !(-e $fileName || -f $fileName || -r $fileName || !-z $fileName));

local $SIG{'INT'} = \&secondChance;

open (my $fh, "+>:utf8", $fileName) or die "Cant get or create file";
$fh->autoflush(1);

# STDOUT autoflush
$| = '1';

die "Cannot interactive " if !is_interactive();

print STDOUT "Get ready\n";

while(is_interactive()) {
    my $echo = <>;
    #Dumper($echo);
    statistic ($echo);
    $SIG{'INT'} = \&secondChance;
    print ($fh $echo);
}

sub statistic {
    my $str = shift;
    if (defined $str){
        chomp($str);        
        $count++;
        $length += length($str);
    } else {
        exit if ($count == 0);

        print (STDOUT (-s $fileName)."\n");    # size
        print (STDOUT $count."\n");            # count
        print (STDOUT sprintf "%d", $length/$count); # avg
        $fh->close();
        exit;
    }
}

sub secondChance {
    print STDERR "Double Ctrl+C for exit";
    $SIG{'INT'} = sub {
        statistic();
    };  
    return unless defined(<>);
}

sub is_interactive {
    return -t STDIN && -t STDOUT;
}

__END__
=head1 NAME
=for pod2usage:
save_stdin - Script with save_stdin
try '--help' to get more info

=head1 SYNOPSIS
stdin [options] [file ...]
Options:
--help                  : this help message
--file [path_to_file]   : file for logging stdin
=cut
