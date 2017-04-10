package Local::SocialNetwork;

use strict;
use warnings;

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

sub getLonely {
    my ($self, $P) = @_;

}

1;
