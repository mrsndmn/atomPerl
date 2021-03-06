package DeepClone;

use 5.010;
use strict;
use warnings;

use DDP;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut
# my $CYCLE_ARRAY = [ 1, 2, 3 ];
# $CYCLE_ARRAY->[4] = $CYCLE_ARRAY;
# $CYCLE_ARRAY->[5] = $CYCLE_ARRAY;

 #p clone ( $CYCLE_ARRAY	);
sub clone {
	my $orig = shift;

	my $recursionLevel = shift;		# when recursionLevel > 0 return CODEref else return undef
	if (!defined $recursionLevel) {$recursionLevel = '0'}

	my $refs = shift;
	#p $refs;
	
	my $cloned;

	my $cl; 	# really my $cl
	#p $orig;
	
	if (!defined $orig) {
		return undef;
	} elsif (ref $orig eq 'HASH') {
		#say 'hAsh';
		my $val;
		foreach my $k (keys %$orig) {
			$val = $$orig{$k};
			if (defined $val && ! exists $refs->{$val}) {
				$refs->{$orig} = 1;						
				$cl = clone($$orig{$k}, $recursionLevel + 1, \%$refs);
				if (ref $val eq 'CODE' || ref $cl eq 'CODE') {
					if (!$recursionLevel){
						return undef;
					} else {
						return sub {};
					}
				}

				$$cloned{$k} = $cl

			} else {
				$$cloned{$k} = $$orig{$k};
			}
		}

	} elsif (ref $orig eq 'ARRAY') {
		#say 'ARR';

		foreach my $elem (@$orig){	
			if ( defined $elem && ! exists $refs->{$elem}){ 	
		
				$refs->{$orig} = 1;						
				$cl = clone($elem, $recursionLevel + 1, \%$refs );
				if (ref $elem eq 'CODE'|| ref $cl eq 'CODE') {
					if (!$recursionLevel) {
						return undef;
					} else {
						return sub {};
					}
				}

				push @$cloned, $cl;				
			} else {
				push @$cloned, $elem;				
			}
		}

	} else {$cloned = $orig}

	if (ref $cloned eq 'CODE') {
		return undef;
	} else {
		return $cloned;
	}
}

1;
