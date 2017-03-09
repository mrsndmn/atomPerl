package Anagram;

use 5.010;
use strict;
use warnings;

use DDP;
#use utf8;
use List::Util qw(all first none any);
use Devel::Peek;
use Encode qw(encode decode);

BEGIN {
    binmode(STDOUT,':utf8');
}

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

$, = ', ';
# my $k = "�";
# $k = decode('utf8', $k);
# say $k;
# say "\x{fffd}";
# Dump $k;
#anagram (['ЛиСток', 'слиток']);

sub anagram {
    my $words_list = shift;
    my %result;
    my ($word, $anagram, $key);

   @$words_list = map {decode ('utf-8', $_)} @$words_list;

    for (my $i=0; $i < scalar (@$words_list); $i++){
        
        $word = $words_list->[$i];        
        next if (any { isAnagram($word, decode ('UTF8', $_)) } keys %result);
        
        for (my $j=$i+1; $j < scalar(@$words_list); $j++){

            $anagram = $words_list->[$j];
            #say $word, $anagram;

            if (isAnagram($word, $anagram)){

                $key = first { isAnagram($anagram, decode ('UTF8', $_)) } keys %result;

                if (defined $key && none { (lc $anagram) eq $_ } @{$result{$key}}) {
                    push @{$result{$key}}, lc $anagram;
               } elsif (!defined $key) {
                    push @{$result{encode ('utf8',lc $word)}}, lc $word, lc $anagram;                    
                }
                
            }
        #
        }   

    }
    

    foreach $key (keys %result) {
        if (scalar(@{$result{$key}} == 1)){
            delete $result{$key};
        } else{
            @{$result{$key}} = map {encode ('utf8', $_)} sort @{$result{$key}};
        }
    }


    return \%result;
}

sub isAnagram {
    my $word = shift;
    my $anagram = shift;

    return (
        length ($word) == length ($anagram) &&
        all {$word =~ /$_/i == $anagram =~ /$_/i} split //, $anagram
        );

} 

1;
