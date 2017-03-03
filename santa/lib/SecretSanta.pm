package SecretSanta;

use 5.010;
use strict;
#use warnings;
use DDP;


sub calculate {
	#say "CALCULATE";
	my @members = @_;
	my @res;

	# get all names
	my @names = map {
		ref() ? @$_ : $_
	} @members;

	die "There won't be any surprise to @names" if ($#names <= 2);
	
	# hash of hashes that realise logic of relations 
	my %cantToGive;

	@cantToGive{@names} = map { {$_ => '1'} } @names; # cause smb cant give present himself 
	
	foreach my $arrRef (@members) {		#cause husb cant give present his wife and vice versa
		if (ref $arrRef) {				#checking arrays
			if (ref $arrRef eq 'ARRAY' && scalar(@$arrRef) == 2) {
			
				my ($husb, $wife) = @$arrRef; # or $wife, $husb -- no matter

				$cantToGive{$husb}{$wife} = 1;
				$cantToGive{$wife}{$husb} = 1;				

			} else {
				die "Bad data: $arrRef"
			}
		}
	}
	#p %cantToGive;	
	# making random pairs, and adding each other to %cantToGive

	my ($from, $to, $toInd);

	# adding each person to %cantToGive{$to}{$everybody} is very slow
	# its better to create new hash that marks persons with present
	my %withGift;

	for my $index (0..$#names) {
		#say $index;
		#say $names[$index];

		$from = $names[$index];

		$toInd = int(rand(scalar(@names)));	#get random '$to'
		$to = $names[$toInd];

		if ( exists $withGift{$to} || isForbiddenToGive($from, $to, \%cantToGive)) { 
			
			# 

			if ($index == $#names && ! exists $withGift{$index} ) { # 

				return	calculate(@members);				#if bad distribution, do it again

			}
			# и, да, эта вещь нужна, т к может получиться, что распределились пары для всех, кроме 2 людей(или даже 1)
			# и тогда они не смогут друг другу подарить подарки
			
			# redo to get another random person
			#say "REDO";
			redo;

		} else {

			$withGift{$to} = '1';
			$cantToGive{$to}{$from} = '1';

			push @res, [$from, $to];
	
		}
	}
	
	#p @res;
	return @res;
}

sub isForbiddenToGive {		# returns true if prohibited
	my ($from, $to, $href) = @_;

	return exists $href->{$from}->{$to};

}


1;
