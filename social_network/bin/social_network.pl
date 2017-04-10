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

given ($command) {
    when('nofriends') {
        
    }

my $confReader = Local::ReadConf->new();

my $conf = $confReader->getConfig(); 

my $dbObj = Local::DBcommunication->new( dbFile => 'soc.db' );

$dbObj->create();
#$dbObj->doIt("insert into users (name, surname) values (qwe, eee);");




