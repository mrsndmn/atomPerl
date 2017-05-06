# from cpan cpypaste
use File::Spec::Functions qw( catdir );
use FindBin qw( $Bin );
use Test::Class::Moose::Load catdir( $Bin, 'lib', 'Local');
use Test::Class::Moose::Runner;
Test::Class::Moose::Runner->new()->runtests;