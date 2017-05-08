# from cpan cpypaste
use File::Spec::Functions qw( catdir );
use FindBin qw( $Bin );
use Test::Class::Moose::Load catdir( $Bin, 'lib', 'Local');
use Test::Class::Moose::Runner;
my $tst_suite = Test::Class::Moose::Runner->new(
    # show_timing => 1,
    # statistics => 1,
    test_classes => ['Local::Test',
                     ],
)->runtests;

# $tst_suite->test_report;