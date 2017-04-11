#!/usr/bin/env perl

use strict;
use warnings;
use DDP;
use 5.010;
use FindBin;
use Getopt::Long;
use feature "switch";
no warnings 'experimental';

use lib "$FindBin::Bin/../lib";

use Local::SocialNetwork;

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
        die "you must determine user with --user=*user*" if scalar(@users)<2;
        my $common = $obj->get_common_friends(@users[0,1]);
        # p $common;
        my $names =  $obj->get_names_by_id($common);
        say $names;
    }
    when ('num_hs') {
        # die "you must determine 2 users with --user=*user*" if !$user1 or !$user2;
        die "you must determine user with --user=*user*" if scalar(@users)<2;        
        my $num_hs = $obj->handshakes(@users[0..1]);
        return $num_hs;
    }
    when ('getID') {
        #say @users[0,1];
        say join ", ", @{$obj->get_id_by_name(@users[0,1])};
    }
    when ('getName') {
        my $id =$users[0];
        die "use --userID to determine ID" if !$id;
        say $obj->get_names_by_id($id);
    }
    default {
        say "bad command"
    }
}    
