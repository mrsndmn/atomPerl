#!/usr/bin/perl

use strict;
use warnings;
use utf8;
=encoding UTF8
=head1 SYNOPSYS

Шифр Цезаря https://ru.wikipedia.org/wiki/%D0%A8%D0%B8%D1%84%D1%80_%D0%A6%D0%B5%D0%B7%D0%B0%D1%80%D1%8F

=head1 encode ($str, $key)

Функция шифрования ASCII строки $str ключем $key.
Пачатает зашифрованную строку $encoded_str в формате "$encoded_str\n"

Пример:

encode('#abc', 1) - печатает '$bcd'

=cut
#encode('#abc', 1);

sub encode {
    my ($str, $key) = @_;
    my $encoded_str = '';

    foreach my $ch (split //, $str){
        # print ord($ch)."\n";
        # my $ok = (ord($ch) + ($key)) % 127  ;
        # print "\t$ok\n";
        $encoded_str = $encoded_str.chr( (ord($ch) + ($key)) % 127 );    
    }

    print "$encoded_str\n";
}

=head1 decode ($encoded_str, $key)

Функция дешифрования ASCII строки $encoded_str ключем $key.
Пачатает дешифрованную строку $str в формате "$str\n"

Пример:

decode('$bcd', 1) - печатает '#abc'

=cut
#decode('$bcd', 1);
sub decode {
    my ($encoded_str, $key) = @_;
    my $str = '';
    
    foreach my $ch (split //, $encoded_str){
        #print $ch."\n";
        $str = $str.chr( (ord($ch) - $key) % 127 );
    }

    print "$str\n";
}

1;
