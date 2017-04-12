#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use notes_web;

notes_web->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    notes_web->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use notes_web;
use Plack::Builder;

builder {
    enable 'Deflater';
    notes_web->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use notes_web;
use notes_web_admin;

builder {
    mount '/'      => notes_web->to_app;
    mount '/admin'      => notes_web_admin->to_app;
}

=end comment

=cut

