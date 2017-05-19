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


my $code_ref = sub {
   my $metric_name = shift;
   return ('avg', 'sum', 'cnt') if $metric_name eq 'metric1';
   return ('avg', 'sum') if $metric_name eq 'm2';
   return ('cnt');
};
my $stt = LocalStat->new($code_ref);
$stt->add('metric1', 1);
$stt->add('m3', 2);
$stt->add('m2', 3);
$stt->add('metric1', 4);
$stt->add('m2', 5);
# warn p $stt;
my $result = $stt->stat;
use DDP;
warn p $result;
# ----
# {
#   metric1 => {avg => 2.5, sum => 5, cnt => 2},
#   m2 => {avg => 4, sum => 8},
#   m3 => {cnt => 1},
# }

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
            avg => 1,
        },
        cnt => {
            cnt => 2,
        },
        sum => {
            
        }
    };

    is($got, 16, 'stat works');
}, $stat;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

