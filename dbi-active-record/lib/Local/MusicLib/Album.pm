package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;
#   Local::MusicLib::DB::SQLite
#/mnt/Data/workSpace/perl/atomPerl/dbi-active-record/lib/Local/MusicLib/DB/SQlite.pm
use DateTime;

warn "db";
db "Local::MusicLib::DB::SQLite";

warn "album";
table 'albums';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field artist_id => (
    isa => 'Int',
    index => 'common',
);

has_field year => (
    isa => 'Int',
    index => 'common',
);

has_field type => (
    isa => 'Str',
    #сингл, саундтрек, сборник, обычный альбом
    
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();