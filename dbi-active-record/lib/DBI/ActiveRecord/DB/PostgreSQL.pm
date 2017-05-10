package DBI::ActiveRecord::DB::PostgreSQL;

use Mouse;
extends 'DBI::ActiveRecord::DB';

with 'DBI::ActiveRecord::DB::CommonSQL';


no Mouse;
__PACKAGE__->meta->make_immutable();

1;