# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl LocalStat.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 4;
BEGIN { use_ok('LocalStat') };

use LocalStat;
use Scalar::Util qw(blessed);

ok(LocalStat->can('new'));

subtest test_counstructor => sub {
    my $code = shift;
    my $stat = LocalStat->new($code);
    
    ok(blessed $stat, "object blessed");
    is($stat->{'code'}, $code, "code ref saved");

}, \&get_metric;


my $stat = LocalStat->new(\&get_metric);

subtest add_metric => sub {
    my $stat = shift;
    
    # $stat->add('cnt', 2);

    eval {
        $stat->add('cnt', 1);
        $stat->add('cnt', 2);
    };


    ok( ! $@ , "add ok");
}, $stat;



sub get_metric {
    my $name = shift; 

    my @list;
    push @list, 'avg' if $name =~ /avg/;
    push @list, 'cnt' if $name =~ /cnt/;
    push @list, 'sum' if $name =~ /sum/;
    push @list, 'min' if $name =~ /min/;
    push @list, 'max' if $name =~ /max/;
    push @list, qw(max min sum cnt avg) if $name =~ /all/;
    
    warn "empty metic\n" if scalar(@list);

    return @list;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

