use strict;
use warnings;

use feature 'say';
use DDP;

use lib 'lib';

use Test::More tests => 4;

BEGIN {
	use_ok('Local::SchedParser');
	use_ok('Local::ToICS');
}

my $schedule = Local::SchedParser->parse('https://home.mephi.ru/study_groups/2190/week?offset=-1');
# p $schedule;

# subtest parsed_ok => sub {
# 	my $schedule = shift;

# 	foreach my $day (@$schedule) {
# 		foreach my $lsn (@$day) {
# 			ok(exists $lsn->{'room'}, 'room exists');
# 			ok(exists $lsn->{'subject'}, 'subject exists');
# 			ok(exists $lsn->{'type'}, 'type exists');
# 		}
# 	}

# }, $schedule;

Local::ToICS->makeICS("session.ics", $schedule);

ok( -f 'session.ics', ".isc exists");