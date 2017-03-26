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
use DDP;

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
				$mode{$who}->{$what} = $rights % 2;
				$rights >>= 1;
			}	
				
		}
		return \%mode;

}

sub parse {
	$, = ", ";
	my $buf = shift;
	my $res;	
#	Dump $buf;
	my $path;

	while (length($buf)) {
		my $op =chr(unpack "c", $buf);
		#Dump $buf;
		$buf = substr $buf, 1; 	# мне это не нравится, наверняка 
					#должен быть какой-то способ, про который я не нашел ничего, чтобы тоже самое делать без таких лишних телодвижений
#		say $op;

		switch ($op) {  
			case ('D') {
				my $dir;

				$dir->{'type'} = 'directory';
				$dir->{'list'} = [];

				my $nameLenght = unpack "n", $buf;
				cut (\$buf, 2);
#				say $nameLenght;

				my $name = join '', map { chr($_) } unpack "C${nameLenght}", $buf;
				cut (\$buf, $nameLenght);
				my $utfName = decode("utf8", $name) or die "wrong name";
				$dir->{'name'} = $utfName;
				

				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$dir->{'mode'} = mode2s($rights);

				if (exists $path->{'list'}){
					push @{$path->{'list'}}, $dir;
				} else {
					$path = $dir;
				}
#				p $path;
			}
			case 'F' {
				die "Cant create file out of directory" if (!defined $path);

				my $file; 
				$file->{'type'} = 'file';

				## the same with dir				
				my $nameLenght = unpack "n", $buf;
				cut (\$buf, 2);
				say $nameLenght;

				my $name = join '', map { chr($_) } unpack "C${nameLenght}", $buf;
				cut (\$buf, $nameLenght);
				my $utfName = decode("utf8", $name) or die "wrong name";
				$file->{'name'} = $utfName;
				
				my $rights = unpack "n", $buf;
				cut (\$buf, 2);
				$file->{'mode'} = mode2s($rights);
				## the same with dir

				my $size = unpack "N", $buf;
				cut (\$buf, 4);				
				my $sha1 = unpack "C20", $buf;

				push @{$path->{'list'}}, $file;
#				p $file;
			}
			case 'I' {
				if (scalar(@{$path->{'list'}})) {
					my $lastCreatedDir = $#{$path->{'list'}};
					$path = $path->{'list'}->[$lastCreatedDir];
#					say "now in $path->{'name'}";
#					p $path;
				} else {
					## what if 2 'I' 'I''
					# die
#					say "now in root directory $path->{'name'}";					
				}

			}
			case 'U' {
				
			}
			case 'Z' {
				# I NEED RECURSION
				#return
			}
			else {
				exit; die "invalid bin";
			}
		}
	
	}

}

1;
