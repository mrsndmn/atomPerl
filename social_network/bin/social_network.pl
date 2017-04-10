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

# given ($command) {
#     when('nofriends') {
        
#     }

my $confReader = Local::ReadConf->new();

my $conf = $confReader->getConfig(); 

my $db = Local::DBcommunication->new( dbFile => 'soc.db' );

#$db->doIt("insert into users (name, surname) values (qwe, eee);");

my $friends_id = $db->get_friends_by_id(1);

# p $friends_id;
my $names = $db->get_names_by_id($friends_id);
# p $names;

p @{Local::SocialNetwork::lonely()};


