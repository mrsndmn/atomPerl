# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl MMultiplier-XS.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More 'no_plan';
BEGIN { use_ok('MMultiplier::XS') };
use MMultiplier::XS;

my $matrix_a = [
[ 1, 2, 3, 4, 5, 6],
[11,12,13,14,15,16],
[21,22,23,24,25,26],
[31,32,33,34,35,36],
[41,42,43,44,45,46],
[51,52,53,54,55,56],
];

my $matrix_b = [
[ 1, 2, 3, 4, 5, 6],
[11,12,13,14,15,16],
[21,22,23,24,25,26],
[31,32,33,34,35,36],
[41,42,43,44,45,46],
[51,52,53,54,55,56],
];

my $matrix_c = [
[ 721,  742,  763,  784,  805,   826],
[2281, 2362, 2443, 2524, 2605,  2686],
[3841, 3982, 4123, 4264, 4405,  4546],
[5401, 5602, 5803, 6004, 6205,  6406],
[6961, 7222, 7483, 7744, 8005,  8266],
[8521, 8842, 9163, 9484, 9805, 10126]
];

my $ans = MMultiplier::XS::doIt($matrix_a, $matrix_b);#for 1..100; # just 0m0.236s while pure perl 0m1.286s
use DDP;
p $ans;
# is_deeply($ans, $matrix_c, "milti ok");


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

