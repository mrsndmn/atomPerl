#!/usr/bin/perl

use strict;
use warnings;
use feature "say";
=encoding UTF8
=head1 SYNOPSYS

Поиск номера первого не нулевого бита.

=head1 run ($x)

Функция поиска первого не нулевого бита в 32-битном числе (кроме 0).
Пачатает номер первого не нулевого бита в виде "$num\n"

Примеры: 

run(1) - печатает "0\n".

run(4) - печатает "2\n"

run(6) - печатает "1\n"

=cut
#run (1);
sub run {
    my ($x) = @_;
    my $num = 0;

    while (not $x & 1){
        $num++;
        $x = $x >> 1;    
    }

    
    print "$num\n";
}

1;
