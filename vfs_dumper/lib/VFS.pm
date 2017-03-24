package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use Encode qw(encode decode);
use Switch;
use Devel::Peek;

# use JSON::XS::True;
# use JSON::XS::False;

no warnings 'experimental::smartmatch';

sub mode2s {
	 	# Тут был полезный код для распаковки численного представления прав доступа
		# но какой-то злодей всё удалил.
		my $rights = shift;
		
		my $otherE = $rights % 2;	$rights = $rights>>1;
		my $otherW = $rights % 2; 	$rights = $rights>>1;
		my $otherR = $rights % 2; 	$rights = $rights>>1;

		my $groupE = $rights % 2; 	$rights = $rights>>1;
		my $groupW = $rights % 2; 	$rights = $rights>>1;
		my $groupR = $rights % 2; 	$rights = $rights>>1;

		my $userE = $rights % 2; 	$rights = $rights>>1;
		my $userW = $rights % 2; 	$rights = $rights>>1;
		my $userR = $rights % 2;	$rights = $rights>>1;
		

}

sub parse {
	$, = ", ";
	my $buf = shift;
	my $res;	
	
	while (length($buf)) {
		my $op =chr(unpack "c", $buf);
		#Dump $buf;
		$buf = substr $buf, 1; 	# мне это не нравится, наверняка 
								#должен быть какой-то способ, про который я не нашел ничего, чтобы тоже самое делать без таких лишних телодвижений
		say $op;
		switch ($op) {
			case ('D'||'F') {
				
				my $nameLenght = unpack "n", $buf;
				$buf = substr $buf, 2;
				say $nameLenght;

				my $name = join '', map { chr($_) } unpack "C${nameLenght}", $buf;
				$buf = substr $buf, $nameLenght;
				say decode("utf8", $name);
				my $rights = unpack "n2", $buf;
				$buf = substr $buf, 2;

				if ($op eq 'F') {
					my $size = unpack "N", $buf;
					$buf = substr $buf, 4;
					my $sha1 = unpack "C20", $buf;
				}

			}
			case 'I' {
				
			}
			case 'U' {
				
			}
			case 'Z' {
				
			}
			else {
				exit; die "invalid bin";
			}
		}
	
	}

}

1;
