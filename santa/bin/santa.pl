#!/usr/bin/env perl

use 5.010;  # for say, given/when
use strict;
use warnings;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
our $VERSION = 1.0;

BEGIN{
	$|++;     # Enable autoflush on STDOUT
	$, = " "; # Separator for print x,y,z
	$" = " "; # Separator for print "@array";
}

use FindBin;
use lib "$FindBin::Bin/../lib";

use SecretSanta;
use DDP;

my @list = map {
	my @v = split /\s+/, $_;
	@v == 1 ? $v[0] : \@v;
} grep { chomp; /\S+/ } <>;

my @names = map {
	ref() ? @$_ : $_
} @list;

my %uniq;

#p @list;

my @members = 'A'..'Z';
my %members; @members{@members} = ();
my @pairs;
for (1..@members/4) {
	my ($one,$two) = keys %members;
	delete $members{$one};
	delete $members{$two};
	push @pairs, [ $one, $two ];
}

my @list = sort { int(rand 3)-1 } @pairs, keys %members;

my @res = SecretSanta::calculate(@list);

for (@res) {
	say join "→", @$_;
}
