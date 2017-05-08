package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;
use Mouse::Util::TypeConstraints;

use DateTime;
use DateTime::Duration;
use DateTime::Format::Strptime;

db "Local::MusicLib::DB::SQLite";

table 'tracks';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 10,
);

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 10,
);

has_field extension => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

#!
subtype 'hh:mm:ss' => {
    as => 'Str',
    where => sub { $_ =~ /^\d\d:\d\d:\d\d$/},
    message => sub { "Wanted hh:mm:ss string" },
};

has_field duration => (
    isa => 'hh:mm:ss',
    serializer => sub {
        my $dur = DateTime::Format::Duration->new( pattern => '%r' )->parse_duration($_[0]);
        my $sec = DateTime::Format::Duration->new( pattern => '%s' )->format_duration($dur);

        return $sec;
    },
    deserializer => sub {
        my $dur = DateTime::Format::Duration->new( pattern => '%r', normalise => 1 );
        my $hms = $dur->format_duration_from_deltas( seconds => $_[0] );

        return $hms;
    },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();