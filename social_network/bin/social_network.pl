#!/usr/bin/env perl

use strict;
use warnings;
use DDP;
use 5.010;
use FindBin;
use Getopt::Long;
use feature "switch";

use lib "$FindBin::Bin/../lib";

use Local::SocialNetwork;
use Local::ReadConf;
use Local::DBcommunication;


my $command = shift;
my ($user1, $user2);
GetOptions ("user=s" => \$user1,
            "user=s" => \$user2,
            );

my $obj = Local::SocialNetwork->new();
p $obj;
given ($command) {
    when('nofriends') {
        my $lonly_ids = $obj->get_lonely();
        p $obj->get_names_by_id($lonly_ids);
    }
    when ('friends') {
        die "you must determine 2 users with --user=*user*" if !$user1 or !$user2;
        print $obj->get_friends($user1, $user2);        
    }
    when ('num_handshakes') {
        die "you must determine 2 users with --user=*user*" if !$user1 or !$user2;
        print $obj->handshakes($user1, $user2);
    }
}    

my $db = Local::DBcommunication->new( dbFile => 'soc.db' );

#$db->doIt("insert into users (name, surname) values (qwe, eee);");
    
# my $friends_id = $db->get_friends_by_id(1);

# p $friends_id;
# my $names = $db->get_names_by_id($friends_id);
# p $names;

# p @{Local::SocialNetwork::lonely()};
warn Local::SocialNetwork->get_names_by_id(1);


