#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры: 

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut
#run(0, 1);
sub run {
    my ($x, $y) = @_;
    my $bool;
    $x = 2 if ($x <= 1);
    for (my $i = $x; $i <= $y; $i++) {
        $bool = 1;

        for (my $divider = 2; $divider <= sqrt($i) ; $divider++ ){
            #my $a = $i % $divider;
            #print "\t$i, $divider, $a\n";
            if ( ($i % $divider) == 0){
                $bool = 0;
                last;
            }
        }
        
        if ($bool) {print "$i\n"}

    }
}

1;
