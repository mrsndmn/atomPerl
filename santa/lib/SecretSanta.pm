package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

$" = ", ";

sub calculate {
	my @members = @_;
	my @res;

	# get all names
	my @names = map {
		ref() ? @$_ : $_
	} @members;

	die "There won't be any surprise to @names" if ($#names <= 2);

	my %cantToGive; # hash of hashes
	@cantToGive{@names} = map {[$_]} @names; # cause smb cant give present himself
	
	foreach my $arrRef (@members) {		#cause husb cant give present his wife and vice versa
		if (ref $arrRef) {				#checking arrays
			if (ref $arrRef eq 'ARRAY' && scalar(@$arrRef) == 2) {
			
				my ($husb, $wife) = @$arrRef; # or $wife, $husb -- no matter

				push @{$cantToGive{$husb}}, $wife;
				push @{$cantToGive{$wife}}, $husb;				

			} else {die "Bad data: $arrRef"}
		}
	}

	#p %cantToGive;	
	# making random pairs, and adding each other to %cantToGive

	my ($from, $to);
	foreach (0..$#names) {
		$from = shift @names;

		
		

	}
	

	exit;
	
	return @res;
}

sub isForbiddeToGive {		# returns true if prohibited
	my ($from, $to, $href) = @_;

	return grep { $_ eq $to } $href->{$from};

}


1;
