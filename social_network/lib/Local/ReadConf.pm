package Local::ReadConf;

use strict;
use warnings;
use DDP;
use List::Util qw(any);
use FindBin; 
use YAML::Tiny;

sub new {
    my ($class, %params) = @_;
    return bless \%params, $class;
}
sub getConfig {
    my $self = shift;
    my $binary_path = $FindBin::Bin;

    my $conf = YAML::Tiny->read( "$binary_path/../etc/social_network.yml" )->[0];
    # p $conf;
    checkConf($conf);

    return $conf;
}

sub checkConf {
    my $conf = shift;
    my %reqiired = ( dbFile => 1);
    my %optional;# = ( handshakes => 1 );

    die "[DEAD] Invalid conf\n",
        "You must specify folowing params:\n",
        join "\n", keys %reqiired
    if any {!exists $conf->{$_}} keys %reqiired;
    
    # i know, its not so good
    #my $unknown;
    #warn "[WARN] Unknown parametr in conf $unknown" if any {!exists $reqiired{$_} and !exists $optional{$_}} grep { $unknown = $_; 1} keys %$conf;
    foreach my $key (keys %$conf) {
        warn "[WARN] Unknown parametr in conf $key" if !exists $reqiired{$key} and !exists $optional{$key};
    }
}

1;