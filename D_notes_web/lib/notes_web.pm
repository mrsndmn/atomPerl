package notes_web;
use Dancer2;
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin/../lib";
use DDP;
use DBcommunication;

our $VERSION = '0.1';

my $db = DBcommunication->new(dbFile => 'web_note.db');

get '/' => sub {
    my $logout = query_parameters->get('logout');
    warn $logout;
    if ($logout) {
        session 'logged_in' => false;
        template 'index' => { 
            'title' => 'Atom notes',
            'msg' => 'Logged out',
        };
    } else {
        template 'index' => { 
            'title' => 'Atom notes',
        };
    }
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
    } elsif ($db->isValid($username, $password)) {
        session 'logged_in' => true;
        redirect '/new-note/'.$username;
    }
    else {
        warn "wrong uname or passwd";
        template 'index', {
            'title' => 'Atom notes',
            'err' => 'Wrong username or password',    
        };
    };
};

get '/register' => sub {
    template 'register' => { 'title' => 'Notes registration' };
};

post '/register' => sub {
    my $username = body_parameters->get('username');
    my $password = md5_hex( body_parameters->get('password') );
    #TODO valid & escape
    warn length $username, length $password;
    if (length($username) < 4 or length($password) < 4 or length($username) > 20 ) {
        warn "SHORT PASSWD OR UNAME\n $username, $password";
        template 'register', {
            'title' => 'Notes registration',
            'err' => 'This username or rassword is too short or too long',
        };
    } elsif ($db->newUser($username, $password)) {
        redirect '/';
    } else {
        template 'register', {
            'title' => 'Atom notes',
            'err' => 'This username is already in use',
        };
    }
};

get '/new-note/:name?' => sub {
    my $username = route_parameters->get('name');
    template 'new-note' => { 
        'title' => 'Atom notes',
        'username' => $username,
        };
};

;
true;