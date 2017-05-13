# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl LocalStat.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use DDP;

use Test::More tests => 5;
BEGIN { use_ok('LocalStat') };

use LocalStat;
use Scalar::Util qw(blessed);

ok(LocalStat->can('new'));

subtest test_counstructor => sub {
    my $code = shift;
    my $stat = LocalStat->new($code);
    
    ok(blessed $stat, "object blessed");
    is($stat->{'code'}, $code, "code ref saved");

    eval {
        my $bad_stat = LocalStat->new("STRING NOT CODEREF");
    };
    ok( $@ , "coderef check");
    
}, \&get_metric;

sub get_metric {
    my $name = shift; 

    my @list;
    push @list, 'avg' if $name =~ /avg/;
    push @list, 'cnt' if $name =~ /cnt/;
    push @list, 'sum' if $name =~ /sum/;
    push @list, 'min' if $name =~ /min/;
    push @list, 'max' if $name =~ /max/;
    push @list, qw(max min sum cnt avg) if $name =~ /all/;

    return @list;
}

my $stat = LocalStat->new(\&get_metric);

subtest add_metric => sub {
    my $stat = shift;
    
    eval {
        $stat->add('cnt', 1);
        $stat->add('cnt', 2);
    };
    ok( ! $@ , "add ok");
    
    my $ans = {
        cnt => {
            params => [qw( cnt )],
            values => [qw(1 2)]
        }
    };

    # p $stat;
    # p $stat->{'metrics'};
    is_deeply($stat->{'metrics'}, $ans, "values and metrics added");
    
    $stat->add('avg', 1);
    $stat->add('sum', 2);
    ok(exists $stat->{'metrics'}->{'avg'}, "more metics");
    ok(exists $stat->{'metrics'}->{'sum'}, "more metics");


    ## todo new metric is empty:!!!!!
    eval {
        my $code = sub { };
        my $bad_stat = LocalStat->new($code);
        $bad_stat->{'code'} = "str";
        $bad_stat->add('cnt', 1);
    };
    ok( $@ , "coderef check in add()");

}, $stat;

subtest stat_metric => sub {
    my $stat = shift;
    my $got;
    
    eval {
        $got = $stat->stat;
    };
    ok( ! $@ , "stat() not dead");

    my $expected = {
        avg => {
            params => [ 'avg' ],
            values  => [ 1 ]
        },
        cnt => {
            params => [ 'cnt' ],
            values  => [ 1, 2 ]
        },
        sum => {
            params => [],
            values  => []
        }
    };

    is_deeply($got, $expected, 'stat works');
}, $stat;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

