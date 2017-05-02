#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use NotesWeb;

NotesWeb->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    NotesWeb->to_app;
}

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use NotesWeb;
use NotesWeb_admin;

builder {
    mount '/'      => NotesWeb->to_app;
    mount '/admin'      => NotesWeb_admin->to_app;
}

=end comment

=cut

