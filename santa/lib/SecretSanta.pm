package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

$" = ", ";

sub calculate {
	my @members = @_;
	my @res;
	p @members;
	# arg validation
	
	# get all names
	my @names = map {
		ref() ? @$_ : $_
	} @members;

	die "There won't be any surprise to @names" if ($#names <= 2);

	my %cantToGive;
	@cantToGive{@names} = map {\[$_]} @names; # cause smb cant give present himself
	
	p %cantToGive;

	foreach my $arrRef (@members) {
		if (ref $arrRef) {
			if (ref $arrRef eq 'ARRAY' && scalar(@$arrRef) == 2) {
				my ($husb, $wife) = @$arrRef; # or $wife, $husb -- no matter



			} else {die "Bad data: $arrRef"}
		}
	}

	p @names;


	exit;
	
	return @res;
}

1;
