package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use Encode qw(encode);
# use JSON::XS::True;
# use JSON::XS::False;

no warnings 'experimental::smartmatch';

sub mode2s {
	
}

sub parse {
	my $buf = shift;
	my @buf = pack "b", $buf;
	my $byte;
	say join ", ",@buf;
	my $op = map {chr($_)}(unpack "C", shift @buf);
	say $op ," | ", @buf;
	if ($op eq 'D') {
		my $nameLenght = (unpack "n", shift @buf);
		say $nameLenght;
		
	}

}

1;
