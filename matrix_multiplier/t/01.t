#!/usr/bin/perl
use lib lib;
use strict;
use warnings;
use Test::More tests => 6;
use_ok("Local::MatrixMultiplier");

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

my $MM = Local::MatrixMultiplier::mult($matrix_a, $matrix_b, 1);
is_deeply($MM, $matrix_c, 'First ok');

eval {
    Local::MatrixMultiplier::mult([[1],[2],[3]], [], 1);
};
is(!$@, '', 'Wrong matrix');

eval {
    Local::MatrixMultiplier::mult([[1,3],[2,4]], [[1,2,3],[4,5,6],[7,8,9]], 1);
};
is(!$@, '', 'Wrong matrix');

eval {
    Local::MatrixMultiplier::mult([[1,3],[2,4]], [[1,2],[4,5],[7,8,9]], 1);
};
is(!$@, '', 'Wrong matrix');

my $A = [
    [1, 2, 3],
    [4, 5, 6]
];

my $B = [
    [7],
    [8],
    [9]
];

my $C = [
    [50],
    [122]
];

my $myMM = Local::MatrixMultiplier::mult($A, $B, 122);
is_deeply($myMM, $C, 'My test ok');