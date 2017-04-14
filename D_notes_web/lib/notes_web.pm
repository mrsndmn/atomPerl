package notes_web;
use Dancer2;
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin/../lib";
use DDP;
use DBcommunication;
use Encode qw(encode);
our $VERSION = '0.1';

my $db = DBcommunication->new(dbFile => 'web_note.db');

get '/' => sub {
    template 'index' => { 
        'title' => 'Atom notes',
    };
};

post '/' => sub {
    my $logout = body_parameters->get('logout');
    if ($logout) {
        session 'logged_in' => false;
        template 'index' => { 
            'title' => 'Atom notes',
            'msg' => 'Logged out',
        };
    } else {
        my $username = body_parameters->get('username');
        chomp $username;
        my $password = md5_hex( encode('utf8',body_parameters->get('password')) );
        #TODO valid & escape
        my $valid_regexp = qr/[^A-Za-z\d_]/;
        if ($username =~ $valid_regexp) {
            template 'index', {
                'title' => 'Atom notes',
                'err' => 'Username can consider letters or numbers or \'_\'',
            };
        } elsif (length($username) < 4 or length($password) < 4) {
            warn "SHORT PASSWD OR UNAME";
            template 'index', {
                'title' => 'Atom notes',
                'err' => 'This username or rassword is too short',
            };
        } elsif ($db->isValid($username, $password)) {
            session 'username' => $username;
            session 'logged_in' => true;
            redirect '/new-note';
        }
        else {
            warn "wrong uname or passwd";
            template 'index', {
                'title' => 'Atom notes',
                'err' => 'Wrong username or password',    
            };
        };
    }
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

get '/new-note' => sub {
    my $username = session('username');
    template 'new-note' => { 
        'title' => 'Atom notes',
        'username' => $username,
        };
};

post '/new-note' => sub {
    template 'new-note' => { 
        'title' => 'Atom notes',
    };
};

;
true;