package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;
use Mouse::Util::TypeConstraints;

use DateTime;

db "Local::MusicLib::DB::SQLite";

table 'album';

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
    default_limit => 100,
);

has_field year => (
    isa => 'Int',
);

#                      сингл  саундтрек  сборник    обычный альбом
enum 'AlbumType', [qw(single soundtrack collection album)];

has_field type => (
    isa => 'AlbumType',
    index => 'common',
    default_limit => 100,    
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();