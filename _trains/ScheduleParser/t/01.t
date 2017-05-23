use strict;
use warnings;

use feature 'say';
use DDP;

use lib 'lib';

use Test::More tests => 2;

BEGIN {
	use_ok('Local::SchedParser');
	use_ok('Local::ToICS');
}

my $shedule = Local::SchedParser->parse('https://home.mephi.ru/study_groups/2190/week?offset=-1');

Local::ToICS->makeICS("session.ics", $shedule);