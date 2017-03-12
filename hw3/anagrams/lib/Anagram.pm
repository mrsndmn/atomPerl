package Anagram;

use 5.010;
use strict;
use warnings;

use DDP;
#use utf8;
use List::Util qw(all first none any);
use Devel::Peek;
use Encode qw(encode decode);


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

#anagram (['ЛиСток', 'слиток']);

sub anagram {
    my $words_list = shift;
    my %result;
    my %abcHash;
    my ($abcword, $k, $key, $abcKey,$word);

   @$words_list = map {decode ('utf-8', $_)} @$words_list;

   # каждому слову сопоставляем слово из тех же букв но поставленных в алфвовитном порядке
   # все добро в хэш, тогда в значение будем добавлять ключ 1 попавшегося слова и через него пушить в %result 
   # хэш хэшэй хэшэй хэшэй
    foreach my $i (0..$#$words_list) {
        $word = lc $$words_list[$i];
        $abcKey = toABC($word);

        if (!exists $abcHash{$abcKey}) {
            $abcHash{$abcKey}->{'keyWord'} = $word;
        }

        $abcHash{$abcKey}->{'hArr'}->{$word} = 1;        

    }

    foreach $key (keys %abcHash) {
        if (scalar(keys %{$abcHash{$key}->{'hArr'}}) > 1){
            #p $abcHash{$key};
            $k = $abcHash{$key}->{'keyWord'};
            $result{$k} = [ sort keys %{$abcHash{$key}->{'hArr'}}];
        }
    }


    return \%result;
}

sub toABC {
    return join ('', sort split (//, shift)); 
}

sub isAnagram {
    my $word = shift;
    my $anagram = shift;

    return (
        length ($word) == length ($anagram) &&
        all {$word =~ s/$_//i} split //, $anagram
        );

} 

1;
