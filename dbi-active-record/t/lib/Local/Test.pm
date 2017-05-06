package lib::Local::Test;

use Test::Class::Moose;

sub test_startup {
    my ($self) = @_;

    $self->next::method();
    
    warn "Test with Test::Class::Moose\n";

    use File::Spec::Functions qw( catdir );
    use FindBin qw( $Bin );
    my $db_path = join "::", $Bin, '..', 'lib', 'Local', 'MusicLib', 'DB';

    $self->{dbh} = $db_path."::"."SQLite";
    return;
}

# sub test_setup {
#     my ($self) = @_;

#     $self->{schema}->txn_begin();

#     return;
# }

# sub test_teardown {
#     my ($self) = @_;

#     $self->{schema}->txn_rollback();

#     return;
# }

1;