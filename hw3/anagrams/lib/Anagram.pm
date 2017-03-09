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

sub anagram {
    my $words_list = shift;
    my %result;
    my ($word, $anagram, $key);

   @$words_list = map {decode ('utf-8', $_)} @$words_list;

    for (my $i=0; $i < scalar (@$words_list); $i++){
        
        $word = lc $words_list->[$i];        
        next if (any { isAnagram($word,  $_) } keys %result);
        
        for (my $j=$i+1; $j < scalar(@$words_list); $j++){

            $anagram = lc $words_list->[$j];
            next if $anagram eq $word;
            #say $word, $anagram;

            if (isAnagram($word, $anagram)){

                $key = first { isAnagram($anagram, $_) } keys %result;
                
                if (defined $key && none {  $anagram eq $_ } @{$result{$key}}) {
                    push @{$result{$key}}, $anagram;
               } elsif (!defined $key) {
                    push @{$result{$word}},$word, $anagram;                    
                }
                
            }
        #
        }   

    }
    

    foreach $key (keys %result) {
        if (scalar(@{$result{$key}} == 1)){
            delete $result{$key};
        } else{
            @{$result{$key}} = sort @{$result{$key}};
        }
    }

    #p %result;
    return \%result;
}

sub isAnagram {
    my $word = shift;
    my $anagram = shift;

    return (
        length ($word) == length ($anagram) &&
        # честно говоря, способ странный, но зато короткий
        all { $word =~ s/$_// } split //, $anagram
        );

} 

1;
