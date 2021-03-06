package VFS;
use utf8;
use strict;
use warnings;
use 5.024;

use JSON::XS;
use Encode qw(encode decode);
use Switch;
use Devel::Peek;
use DDP;
use File::Basename;
use File::Spec::Functions qw{catdir};
no warnings 'experimental::smartmatch';

sub mode2s {
		my $rights = shift;
		my $json = JSON::XS->new();
		my %mode;
		foreach my $who (qw(other group user)) {
			foreach my $what (qw(execute write read)) {
				$mode{$who}->{$what} = $rights % 2 ? $json->true : $json->false ;
				$rights >>= 1;
			}	
		}
		return \%mode;
}

sub parse {
	my $buf = shift;
	my $res = {};
	#Dump $buf;
	my @history;
	my @path;
	my %contains;

	while (length($buf)) {
		my $op;
		($op, $buf) = unpack "A(a*)", $buf;
		#Dump $buf;
		#warn $op;
		switch ($op) {  
			case 'D' {
				my $dir;
				$dir->{'type'} = 'directory';
				$dir->{'list'} = [];

				my ($name, $rights);
				($name, $rights, $buf) = unpack("(n/A)(n)(a*)", $buf);

				die "Such directory already exists" if ( scalar(@path) and $contains{catdir(@path)}->{'directory'}->{$name} );
				#say "DIR: ", $dir->{'name'};
				$dir->{'name'} = decode("utf8", $name);
				$dir->{'mode'} = mode2s($rights);

				if (exists $res->{'list'}) {
					push @{$res->{'list'}}, $dir;
					$contains{catdir(@path)}->{'directory'}->{$name} = 1;
				} else {
					# if its root directory
					$res = $dir;
					push @history, $res;
					push @path, $dir->{'name'};
					#p @path;
				}
			}
			case 'F' {
				die "Cant create file out of directory" if (!scalar(keys %$res));

				my $file; 
				$file->{'type'} = 'file';

				my ($name, $rights, $size, $sha1);
				($name, $rights, $size, $sha1, $buf) = unpack("(n/A)(n)(N)(H40)(a*)", $buf);

				die "Such file already exists" if (scalar(@path) and $contains{catdir(@path)}->{'file'}->{$name} );
				#say "FILE: ", $file->{'name'};
				$file->{'name'} =  decode("utf8", $name);
				$file->{'mode'} = mode2s($rights);
				$file->{'size'} = $size;
				$file->{'hash'} = $sha1;

				push @{$res->{'list'}}, $file;
				$contains{catdir(@path)}->{'file'}->{$name} = 1;
			}
			case 'I' {
				#warn "in I";
				if (exists $res->{'list'} and scalar(@{$res->{'list'}})) {
					my $lastCreatedDir = $#{$res->{'list'}};
					$res = $res->{'list'}->[$lastCreatedDir];
					push @history, $res;
					push @path, $res->{'name'};
					#p @path;					
					#warn "!now in $res->{'name'}";
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
					pop @path;
					#p @path;					
					#p $res;
				} else {
					if ('Z' ne unpack "A", $buf) {
						die "cant go upper here. Alredy in root. ";
					}
				}
				#warn "!upto ", $res->{'name'};
			}
			case 'Z' {
				#p $res;
				#p %contains;
				if (length($buf)) {
					die "Garbage ae the end of the buffer";
				} elsif (scalar(@history)>1) {
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
