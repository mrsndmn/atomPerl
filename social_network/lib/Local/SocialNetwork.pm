package Local::SocialNetwork;

use strict;
use warnings;

use DDP;
use List::Util qw(any);

use JSON::XS;
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

sub new {
    my ($class, %params) = @_;
    my $confReader = Local::ReadConf->  new();
    my $conf = $confReader->getConfig(); 
    my $dbFile = $conf->{dbFile};
    my $db = Local::DBcommunication->new( dbFile => $dbFile );
    $params{'db'} = $db;
    $params{'toJSON'} = JSON::XS->new->pretty;
    return bless \%params, $class;
}

sub get_names_by_id {
    my ($self, $ids) = @_;
    my $db = $self->{'db'};
    $ids = [ $ids ] if (ref $ids eq '');  
    my $arrref = $db->select_names_by_id($ids);
    return $self->{'toJSON'}->encode($arrref);
} 

sub get_id_by_name {
    my ($self, $name, $surname) = @_;
    my $db = $self->{'db'};
    return $db->select_id_by_name($name, $surname);
}

sub get_lonely {
    my ($self) = @_;
    my $db = $self->{'db'};
    my $foreverAlone = $db->select_lonely;
    return $foreverAlone;
}

sub get_common_friends {
    my ($self, $id0, $id1) = @_; 
    # p @_;
    my $db = $self->{'db'};     
    return $db->select_common_friends($id0, $id1);
}

sub get_all_friends {
    my ($self, $ids) = @_;
    my $db = $self->{'db'};
    die "need arrref as args" if !$ids;
    $ids = [ $ids ] if (ref $ids eq '');
    return $db->select_friends_by_id($ids);
}

sub handshakes {
    my ($self, $id0, $id1) = @_;
    my $db = $self->{'db'};
    die "need id1, id2 as args" if ! $id0 or !$id1;
    return 0 if $id0 == $id1;
    
    my $lonly = $self->get_lonely;
    return "there is no hope to get handshake with alone" if any { $_ == $id0 or $_ == $id1 } @$lonly;

    my $users_count = $db->select_count_users();
    my $lim = $users_count - scalar(@$lonly);

    my %index;

    my $friends;# = $self->get_all_friends([$id0]) ; #its arr
    push @$friends, $id0;
    my $ans_hshake;

    my $shakes = 1;
    while ((scalar(@{[keys %index]})<$lim and !$ans_hshake) or scalar @$friends == 0 ){
        
        #! but may be with EXCEPT in db it would be better, but i'm too lazy
        @$friends = grep { !exists $index{$_} } @{ $self->get_all_friends($friends) };        
 
        foreach my $friend (@$friends) {
            $index{$friend} = $shakes;
            if ($id1 == $friend) {
                $ans_hshake = $shakes;
                last;
            }
        }
        $shakes++;
    }
    # warn "YYYYEEEAH ", $ans_hshake;
    return $ans_hshake? $ans_hshake : "no common friends" ;
}

1;
