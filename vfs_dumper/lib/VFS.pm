package VFS;
use utf8;
use strict;
#use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use Encode qw(encode decode);
use Switch;
use Devel::Peek;
use DDP;
use List::Util qw(any);
#use Types::Serialier;

# use JSON::XS::True;
# use JSON::XS::False;

no warnings 'experimental::smartmatch';


sub cut {			# i think, exist another way, but i dont know it (())
    my ($what, $howMuch) = @_;
    $$what =  substr $$what, $howMuch;
}

sub mode2s {
	 	# Тут был полезный код для распаковки численного представления прав доступа
		# но какой-то злодей всё удалил.
		my $rights = shift;

		my %mode;
		foreach my $who (qw(other group user)) {
			foreach my $what (qw(execute write read)) {
				my $json = JSON::XS->new();
				$mode{$who}->{$what} = $rights % 2 ? $json->true : $json->false ;
				$rights >>= 1;
			}	
				
		}
		return \%mode;
}

sub getName {
	my $bufref = shift;
	
	my $nameLenght = unpack "n", $$bufref;
	cut ($bufref, 2);

	my $name =  pack "U${nameLenght}",  unpack "W${nameLenght}", $$bufref;
	cut ($bufref, $nameLenght);
	
	return decode("utf8", $name);
}

sub parse {
	#$, = ", ";
	my $buf = shift;
	my $res = {};	
	Dump $buf;
	
	my @history;	# to avoid recursion
					# хотя с рекурсией решение, может быть, было бы более элегантным
					# но я с расчетом на то, что может быть большая вложенность, забьется стэк -> stack overflow, deep recursion по перловому

	while (length($buf)) {
		my $op =chr(unpack "c", $buf);
		#Dump $buf;
		cut (\$buf, 1); 	# мне это не нравится, наверняка 
							# должен быть какой-то способ, про который я не нашел ничего, чтобы тоже самое делать без лишних телодвижений
							# но как?
		warn $op;

		switch ($op) {  
			case 'D' {
				my $dir;

				$dir->{'type'} = 'directory';
				$dir->{'list'} = [];

				my $name = getName(\$buf);

				# для этого дела хорошо бы завести хэш, но мне кажется, в настоящей vfs
				# list или как-то сразу сортируется, или 
				# 'any' from List::Util
				die "Such directory already exists" if (any { $_->{'type'} eq 'directory' and $_->{'name'} eq $name } @{$res->{'list'}});

				$dir->{'name'} = $name;
				say "DIR: ", $dir->{'name'};

				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$dir->{'mode'} = mode2s($rights);

				if (exists $res->{'list'}){
					push @{$res->{'list'}}, $dir; 
				} else {
					# if its root directory
					$res = $dir;
					push @history, $res;
					
				}
				#p $res;
			}
			case 'F' {
				die "Cant create file out of directory" if (!scalar(keys %$res));

				my $file; 
				$file->{'type'} = 'file';

				my $name = getName(\$buf);
				
				die "Such file already exists" if (any { $_->{'type'} eq 'file' and $_->{'name'} eq $name } @{$res->{'list'}});				
				
				$file->{'name'} =  $name;
				say "FILE: ", $file->{'name'};
				
				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$file->{'mode'} = mode2s($rights);
				## the same with dir

				my $size = unpack "N", $buf;
				cut (\$buf, 4);
				$file->{'size'} = $size;
				
				my $sha1 =  unpack "H40",  $buf;
				cut (\$buf, 20);
				$file->{'hash'} = $sha1;

				push @{$res->{'list'}}, $file;
				#p $file;
			}
			case 'I' {
				#warn "in I";
				if (exists $res->{'list'} and scalar(@{$res->{'list'}})) {
					my $lastCreatedDir = $#{$res->{'list'}};
					$res = $res->{'list'}->[$lastCreatedDir];
					push @history, $res;
					warn "!now in $res->{'name'}";
				} elsif (!scalar(keys %$res)) {
					die "The blob should start from 'D' or 'Z'" 
				}
				#warn "*******", $res->{'name'};				

			}
			case 'U' {
				if (scalar(@history)>1) {
					#p @history;
					my $oldDir = pop @history;
					$res = $history[$#history];
					my $last = $#{$res->{'list'}};
					$res->{'list'}->[$last] = $oldDir;
					#p $res;
				} else {
					if ('Z' eq chr(unpack "c", $buf)) {
						warn "ok, you are in root";
						# but it changes nothing, i think
					} else {
						die "cant go upper here. Alredy in root. ";
					}
				}
				warn "!upto ", $res->{'name'};
			}
			case 'Z' {
				#p $res;
				if (length($buf)) {
					die "Garbage ae the end of the buffer";
				} elsif (scalar(@history)>1) {
					#p @history;
					# or do it auto?
					# 
					die "you should up to root";
				}
				return $res;
			}
			else {
				warn "!!!!its wrong ", $op; 
				die "invalid bin";
			}
		}
	
	}
	die "binary must ended with Z"

}

1;
