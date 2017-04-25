#!/usr/bin/env perl
use strict;
use warnings;
use DDP;
use 5.010;
use Getopt::Long;
use FindBin;
use feature "switch";
no warnings 'experimental';

use lib "$FindBin::Bin/../lib";

use Local::SocialNetwork;

=head1 NAME

    SocialNetwork app

=head1 SYNOPSIS

    Usage :

        $0 command --options

    Commands:

        nofriends -- without options. Find lonely people.

        friends -- Find common friends

                With option --user {id1} --user {id2}
        
        num_hs -- The least handshakes num between users
    
                With option --user {id1} --user {id2}

        getID -- Gettind dis of users with folowing name and surname

                With option --userName {name} {surname}               

        getName -- Getting name by id

                With option --user {id1}
        
=cut

my $command = shift;
my @users;
my @userName;
GetOptions ("userName=s{2}" => \@userName,
            "user=i" => \@users,
            );

my $obj = Local::SocialNetwork->new();

given ($command) {
    when('nofriends') {
        my $lonly_ids = $obj->get_lonely();
        my $names =  $obj->get_names_by_id($lonly_ids);
        say $names;
    }
    when ('friends') {
        die "you must determine both users with --user=*userID*" if scalar(@users)<2;
        my $common = $obj->get_common_friends(@users[0,1]);
        #my $names =  $obj->get_names_by_id($common);
        say join "\n", @$common;
    }
    when ('num_hs') {
        die "you must determine both users with --user=*userID*" if scalar(@users)<2;        
        my $num_hs = $obj->handshakes(@users[0..1]);
        say $num_hs;
    }
    when ('getID') {
        say join ", ", @{$obj->get_id_by_name(@userName[0,1])};
    }
    when ('getName') {
        my $id =$users[0];
        die "use --user to determine ID" if !$id;
        say $obj->get_names_by_id($id);
    }
    default {
        say "bad command"
    }
}    

