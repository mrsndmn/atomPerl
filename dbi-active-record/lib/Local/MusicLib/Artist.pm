package Local::MusicLib::Artist;

use DBI::ActiveRecord;
use Local::MusicLib::DB::PostgreSQL;
use Mouse::Util::TypeConstraints;

use DateTime;

db "Local::MusicLib::DB::PostgreSQL";

table 'artist';

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

subtype 'country_code', {
    as => 'Str',
    where => sub { $_ =~ /^\w{2}$/},
    message => sub { "Wanted 2 symbol country_code" },
};

has_field country => (
    isa => 'country_code',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();
