package Local::SocialNetwork;

use strict;
use warnings;

use DDP;
use List::Util qw(any);


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
    my ($self, $ids) = @_;
    my $friends_id = $db->select_friends_by_id($ids);
    return $friends_id;
}

sub handshakes {
    my ($self, $id0, $id1) = @_;
    return 0 if $id0 == $id1;
    
    my $lonly = get_lonely;
    return "there is no hope to get handshake with alone" if any { $_ == $id0 ot $_ == $id1 } @$lonly;

    my $users_count = $db->select_count_users();
    my $lim = $users_count - scalar(@$lonly);

    my %index;
    $index{$id0}->{'handshakes'} = 0;
    $index{$id0}->{'prev'} = undef;
    my $friends = get_friends($id0) ; #its arr

    my $ans_hshake;
    my $prev = $id0;
    $index{$_} = 1 foreach (@$friends);

    while (scalar(@{[keys %index]})<$lim or !$ans_hshake ){

        foreach my $friend (@$friends) {
            # if (!exists $index{$friend}) {
            $index{$friend}->{'handshakes'} = 1 + $index{$prev}->{'handshakes'};
            $index{$friend}->{'prev'} = $prev;

            if ($id1 == $friend) {
                $ans_hshake = $index{'handshakes'};
                last;
            }
            # }
        }
        $friends = grep { !exists $index{$_} } @{ get_friends($friends) };

    }
    
    return $hshake;
}

1;
