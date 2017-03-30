#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use 5.010;
use JSON::XS;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use VFS;
use DDP;

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
VFS::parse($buf);

# Вот досада, JSON получается трудночитаемым, совсем не как в задании.
#print JSON::XS->new->pretty->encode(VFS::parse($buf));
