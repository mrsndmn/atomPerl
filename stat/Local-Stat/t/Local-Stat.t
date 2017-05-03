# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Local-Stat.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use lib 'lib';

use Test::More tests => 3;
BEGIN { use_ok('Local::Stat') };

#########################
# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
use Local::Stat;
use DDP;

my $obj = Local::Stat->new_metric(sub {qw/min max avg/});
ok ($obj->{'code'});
p $obj->{'code'};
is(join (" ", &{$obj->{'code'}}), "min max avg" , 'Code in constructor');
