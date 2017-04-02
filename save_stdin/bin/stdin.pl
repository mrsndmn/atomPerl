#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Data::Dumper;

#use 5.024;
use feature 'state';

my ($needHelp, $fileName);

=head1 NAME

save_stdin - Script with save_stdin
try '--help' to get more info

=head1 SYNOPSIS

stdin [options] [file ...]

Options:

--help                  : this help message

--file [path_to_file]   : file for logging stdin

=cut

GetOptions (
    "file=s" => \$fileName,
    'help|?' => \$needHelp
) or pod2usage(1);

pod2usage(2) if ($needHelp || !defined $fileName);

$SIG{'INT'} = \&secondChance;

open (my $fh, "+>:utf8", $fileName) or die "Cant get or create file";
$fh->autoflush(1);

# STDOUT autoflush
$| = '1';

syswrite STDOUT, "Get ready\n";

my $ctlC = 0;

$SIG{'INT'} = \&secondChance;

while(my $echo = <STDIN>) {
    statistic($echo);
    print $fh $echo;
    $ctlC = 0 if ($ctlC > 0);
}


$fh->close();        
statistic();

sub statistic {
    my $str = shift;
    state $length = 0;
    state $count = 0;

    if (defined $str){
        chomp($str);
        $count++;
        $length += length($str);
    } else {
        exit if ($count == 0);

        syswrite (STDOUT, $length." ", length($length." "));    # size   
        syswrite (STDOUT, $count." ", length($count." "));   # count
        
        my $avg = sprintf "%d", ($length/$count);
        syswrite (STDOUT, $avg, length($avg)); # avg
        exit;
    }
}

sub secondChance {
    $ctlC++;
    if ($ctlC == 2) {
        $fh->close();        
        statistic();
        exit;
    } else {
        print STDERR "Double Ctrl+C for exit";    
    }

}

