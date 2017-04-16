package notes_web;
use Dancer2;
use HTML::Entities;

use Digest::MD5 qw(md5_hex);
use Digest::CRC qw(crc32);
use DDP;
use Encode qw(encode);
our $VERSION = '0.1';

use FindBin;
use lib "$FindBin::Bin/../lib";
use DBcommunication;
use Devel::Peek;

my $db = DBcommunication->new(dbFile => 'web_note.db');

get '/' => sub {
    template 'index' => { 
        'title' => 'Atom notes',
    };
};

post '/' => sub {
    my $logout = body_parameters->get('logout');
    if ($logout) {
        app->destroy_session;
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
            session 'user_id' => $db->wantID($username);
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
    my $user_id = session('user_id');
    my $username = session('username');
    
    if (!session('logged_in')) {
        # will ask to auth
        redirect '/';
    }

    my $notes = $db->getNotes($user_id);
    p $notes;
    session 'notes' => $notes;
    
    template 'new-note' => { 
        'title' => 'Atom notes',
        'username' => $username,
    };

};

post '/new-note' => sub {
    my $username = session('username');
    my $user_id = session('user_id');
    my $title = body_parameters->get('title') || 'Untitled';
    my $text = body_parameters->get('text');
    my $sharing = body_parameters->get('share');
     warn "session", session('logged_in');
    if (!session('logged_in')) {
        # will ask to auth
        redirect '/';

    } elsif (!$text) {
        template 'new-note' => { 
            'title' => 'Atom notes',
            'username' => $username,
            'err' => 'fill the \'text\' field',
        };
    } else {
        foreach my $input ($title, $text) {
            #encode_entities($input, '<>&"')
        }

        my $time = time;
        my $note_id = '';
        my $try_count = 10;

        while ($try_count--) {
            $note_id = crc32 ($title.$time.$note_id);
            last if !$db->note_id_exists($note_id);
        }
        #Devel::Peek::Dump($sharing);
        my @sharingUsers =@{[ split '\r\n', $sharing ]};
        #Devel::Peek::Dump($sharingUsers[0]);        
        
        my $errors = $db->new_note($note_id, $user_id, $time, $title, $text, \@sharingUsers);

        #warn join "\n", $username, $title, $text, $sharingUsers, $note_id;

        my $notes = $db->getNotes($user_id);
        # p $notes;
        session 'notes' => $notes;

        template 'new-note' => { 
            'title' => 'Atom notes',
            'username' => $username,
        };
    }
};

get qr{^/note/([a-f0-9]{8})$} => sub {
    my ($note_id) = splat;
    my $id = unpack 'L', pack 'H*', $note_id;

    my $note = $db->want_note($id);

    template 'get-note' => {
        'note' => $note,
    };

};

true;