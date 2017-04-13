package notes_web;
use Dancer2;
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin/../lib";

use DBcommunication;

our $VERSION = '0.1';

my $db = DBcommunication->new(dbFile => 'web_note.db');

get '/' => sub {
    template 'index' => { 'title' => 'Atom notes' };
};

post '/' => sub {
    my $username = body_parameters->get('username');
    my $password = md5_hex( body_parameters->get('password') );
    #TODO valid & escape
    if (length($username) < 4 or length($password) < 4) {
        warn "SHORT PASSWD OR UNAME";
        template 'index', {
            'title' => 'Atom notes',
            'err' => 'This username or rassword is too short',
        };
    } elsif (! $db->isValid($username, $password)) {
        warn "wrong uname or passwd";
        template 'register', {
            'title' => 'Atom notes',
            'err' => 'Wrong username or password',
        };
    } else {
        session 'logged_in' => true;
        template 'index', {
            'title' => 'Atom notes',
            'msg' => "Hello, ".$username,
        }
    };
};

get '/register' => sub {
    template 'register' => { 'title' => 'Notes registration' };
};

post '/register' => sub {
    my $username = body_parameters->get('username');
    my $password = md5_hex( body_parameters->get('password') );
    #TODO valid & escape
    if (length($username) < 4 or length($password) < 4 or length($username) > 20 or length($password) > 20 ) {
        warn "SHORT PASSWD OR UNAME";
        template 'register', {
            'title' => 'Notes registration',
            'err' => 'This username or rassword is too short or too long',
        };
    } elsif ($db->newUser($username, $password)) {
        redirect '/';
        template 'index', {
            'title' => 'Atom notes',
            'msg' => 'Registration succeed',
        };
    } else {
        template 'register', {
            'title' => 'Atom notes',
            'err' => 'This username is already in use',
        };
    }
};


true;