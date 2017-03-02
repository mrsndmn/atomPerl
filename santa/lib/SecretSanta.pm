package SecretSanta;

use 5.010;
use strict;
#use warnings;
use DDP;
use List::Util qw(any);

sub calculate {
	my @members = @_;
	my @res;

	# get all names
	my @names = map {
		ref() ? @$_ : $_
	} @members;

	die "There won't be any surprise to @names" if ($#names <= 2);

	my %cantToGive; # hash of hashes
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

	my ($from, $to, $ind);
	
	for $from (@names) {
		
		$ind = int(rand(scalar(@names)));	#get random '$to'
		$to = $names[$ind];

		if (isForbiddenToGive($from, $to, \%cantToGive)) { 
			#check if we cant make any pair

			if ( any { $cantToGive{$from}{$to} } @names  ) { 	# 'any' provided by List::Util
					#say "ANY!!!";								# to see it really need
					return 	calculate(@members);				#if bad pairs, do it again
			}
			# и, да, эта вещь нужна, т к может получиться, что распределились пары для всех, кроме 2 людей(или даже 1)
			# и тогда они не смогут друг другу подарить подарки


			redo;
		} else {
			
			foreach my $frm (@names) {			# its forbidden to give more than 1 gift to 1 person
				$cantToGive{$frm}->{$to} = 1;	# but that is very slowly
												# 
												# >> [Done] exited with code=0 in 164.007 seconds
												#
												# so, think, its better to create new array
			}
			
			$cantToGive{$to}->{$from} = 1;
			push @res, [$from, $to];

			p %cantToGive;			
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
