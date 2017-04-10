package Local::SocialNetwork;

use strict;
use warnings;


use Local::ReadConf;
use Local::DBcommunication;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut
# get friends
# select id, name from users join relations on relations.first_id == 35648 and relations.second_id == users.id ;


my $db = Local::DBcommunication->new( dbFile => 'soc.db' ) or die "Cant connect to DB";

sub get_lonely {
    my ($self) = @_;
    my $foreverAlone = $db->select_lonely;
    return $foreverAlone;
}

sub get_friends {
    my ($self, $id) = @_;
    my $friends_id = $db->select_friends_by_id($id);
    return $friends_id;
}

sub handshakes {
    my ($self, $id0, $id1) = @_;
    return 0 if $id0 == $id1;
    
    my %index;
    $index{$id0}->{'handshakes'} = 0;
    $index{$id0}->{'prev'} = undef;
    my $friends = get_friends($id0) ; #its arr

    my $hshake = 1;

    
    foreach my $friend (@$friends) {
        if !exists $index{$friend} {
            $index{$friend}->{} = $hshake;
        } else {
            if ($index{$friend}>$hshake) {

            }
        }
    }
    
    return $hshake;
}

1;
