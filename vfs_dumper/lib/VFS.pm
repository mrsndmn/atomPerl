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
 no warnings;
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

sub parse {
	#$, = ", ";
	my $buf = shift;
	my $res;	
	Dump $buf;
	my $path;
	my $history;

	while (length($buf)) {
		my $op =chr(unpack "c", $buf);
		#Dump $buf;
		cut (\$buf, 1); 	# мне это не нравится, наверняка 
							# должен быть какой-то способ, про который я не нашел ничего, чтобы тоже самое делать без лишних телодвижений
		say $op;

		switch ($op) {  
			case 'D' {
				my $dir;

				$dir->{'type'} = 'directory';
				$dir->{'list'} = [];

				my $nameLenght = unpack "n", $buf;
				cut (\$buf, 2);

				my $name =  pack "U${nameLenght}",  unpack "W${nameLenght}", $buf;
				cut (\$buf, $nameLenght);

				$dir->{'name'} = decode("utf8", $name);
				say "DIR: ", $dir->{'name'};

				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$dir->{'mode'} = mode2s($rights);

				if (exists $path->{'list'}){
					push @{$path->{'list'}}, $dir; # if already no file the same name
	
				} else {
					# if its root directory
					$path = $dir;
					$history->{'now'} = $path;
					$history->{'prev'} = undef;
					$res = $path;
				}
				#p $path;
			}
			case 'F' {
				die "Cant create file out of directory" if (!defined $path);

				my $file; 
				$file->{'type'} = 'file';

				## the same with dir				
				my $nameLenght = unpack "n", $buf;
				cut (\$buf, 2);
				#say $nameLenght;

				my $name =  pack "U${nameLenght}", unpack "W${nameLenght}", $buf;
				cut (\$buf, $nameLenght);
				
				$file->{'name'} =  decode("utf8", $name);
				say "FILE: ", $file->{'name'};
				
				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$file->{'mode'} = mode2s($rights);
				## the same with dir

				my $size = unpack "N", $buf;
				cut (\$buf, 4);
				$file->{'size'} = $size;
				
				#sDump $buf;
				my $sha1 =  unpack "H40",  $buf;
				cut (\$buf, 20);
				$file->{'hash'} = $sha1;

				push @{$path->{'list'}}, $file;
				#p $file;
			}
			case 'I' {
				if (scalar(@{$path->{'list'}})) {
					my $lastCreatedDir = $#{$path->{'list'}};
					$path = $path->{'list'}->[$lastCreatedDir];
					#warn "inside", p $path;
					#warn p $history->{'prev'};
					warn $history->{'now'}->{'name'};
					$history->{'prev'} = \%{$history};
					warn $history->{'prev'}->{'now'}->{'name'};
					$history->{'now'} = $path;
					#say keys %{$history->{'prev'}};
					#say keys %{$history->{'now'}};
					warn "now in $path->{'name'}";
				} else {
					warn "Why am i here", p @{$path->{'list'}};
					## what if 2 'I' 'I'
					# die
					#warn "now in root directory $path->{'name'}";					
				}
				#warn "*******", $path->{'name'};				

			}
			case 'U' {
				print ($history->{'prev'}) ; print ($history);
				#$history = $history->{'prev'}->{'now'};
				$path = $history->{'now'};
				warn "*******", $path->{'name'};
			}
			case 'Z' {
				p $res;		
				return $res;
			}
			else {
				warn "!!!!its wrong", $op; 
				exit;
				die "invalid bin";
			}
		}
	
	}
	die "binary must ended with Z"

}

1;
