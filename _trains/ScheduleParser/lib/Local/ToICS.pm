package Local::ToICS;

use strict;
use warnings;

# use 5.022;
use DDP;
use Tie::iCal;

sub makeICS {
	my ($self, $fileName, $shedule) = @_; 

	my %guts;	

	tie %guts, 'Tie::iCal', $fileName or die "Failed to tie file!\n";

	my $first = shift @$shedule;

}


1;