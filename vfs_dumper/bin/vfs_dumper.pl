#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use 5.010;
use JSON::XS;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use VFS;
use Devel::Peek;

our $VERSION = 1.0;

binmode STDOUT, ":utf8";

unless (@ARGV == 1) {
	die "$0 <file>\n";
}

my $file = shift;

open (my $fh, "<:raw", "$FindBin::Bin/../".$file)  if(-e $file and -f $file and
															-r $file and !-z $file)
															or die "File Error";
$fh->autoflush(1);
my $buf;
{
	local $/ = undef;
	$buf = <$fh>;
	#say $buf;
	#Dump $buf;
}
VFS::parse("D\0\4root\1\375ID\0\22\320\224\320\276\320\272\321\203\320\274\320\265\320\275\321\202\321\213\1\375I");

# Вот досада, JSON получается трудночитаемым, совсем не как в задании.
#print JSON::XS->pretty->encode_json(VFS::parse($buf));
