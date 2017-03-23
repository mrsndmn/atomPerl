#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use 5.022;
use Data::Dumper;

my ($needHelp, $fileName);

GetOptions (
    "file=s" => \$fileName,
    'help|?' => \$needHelp
) or pod2usage(-exitval => 0, -verbose => 1);

pod2usage(2) if ($needHelp || !defined $fileName);

# die "No such file ${fileName}" if ( !(-e $fileName || -f $fileName || -r $fileName || !-z $fileName));

local $SIG{'INT'} = \&secondChance;

say $fileName;

open (my $fh, "+>", $fileName) or die "Cant get fileHandler";
$fh->autoflush(1);

die "Cannot interactive " if !is_interactive();

say "Get ready";

while(is_interactive()) {
    my $echo = <>;
    if (!defined $echo){
        say sastistic();
    }
    $SIG{'INT'} = \&secondChance;
    
    print $fh $echo;
}
my ($size, $length, $count) = qw(0 0 0);

sub sastistic {
    my $str = shift;
    if (defined $str){
        $count++;
    } else {

        $fh->close();
    }

}

sub secondChance {
    print STDERR "Double Ctrl+C for exit";
    $SIG{'INT'} = 'DEFAULT';   
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
