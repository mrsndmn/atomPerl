package NotesWeb;
use Dancer2;
use Dancer2::Plugin::CSRF;
use HTML::Entities;

use Digest::MD5 qw(md5_hex);
use Digest::CRC qw(crc32);
use Encode qw(encode);
our $VERSION = '0.1';

use FindBin;
use lib "$FindBin::Bin/../lib";
use DBcommunication;
use ReadConf;

my $confReader = ReadConf->new();
my $conf = $confReader->getConfig(); 
my $dbFile = $conf->{dbFile};
my $db = DBcommunication->new(dbFile => $dbFile);

hook before => sub {
        if ( request->is_post() ) {
                my $csrf_token = body_parameters->get('csrf_token');
                warn $csrf_token;
                if ( !$csrf_token or !validate_csrf_token($csrf_token) ) {
                        redirect '/?err=2';
                }
        }
};

get '/' => sub {
    my $err;
    if (params('query')) {
        my $err_n = params('query')->{'err'};
        $err = {
            1 => "Wrong username or password",
            2 => "CSRF prevented",
        }->{$err_n};
    }

    template 'index' => { 
        csrf_token => get_csrf_token(),
        title => 'Atom notes',
        err => $err,
    };
};

post '/' => sub {
    my $logout = body_parameters->get('logout');
    if ($logout) {
        app->destroy_session;
        redirect '/';
    } else {
        my $username = body_parameters->get('username');
        chomp $username;
        my $password = md5_hex( encode('utf8',body_parameters->get('password')) );
        #TODO valid & escape
        # \w загребает русски буквы тоже, мне это не нужно, кроме того
        # всякие запятые и другие пунктационные символы, тогда их нужно будет эскейпить еще, лучше пусть будет как есть
        my $valid_regexp =  qr/[A-Za-z_]{4,20}/;
        if ($username !~ $valid_regexp) {
            template 'index', {
                'title' => 'Atom notes',
                'err' => 'Username can consider letters or numbers or \'_\'. Or too short username.',
            };
        } elsif (length($password) < 4) {
            template 'index', {
                'title' => 'Atom notes',
                'err' => 'This username or rassword is too short',
            };
        } elsif ($db->is_valid($username, $password)) {
            session 'username' => $username;
            session 'user_id' => $db->want_column('id', $username);
            session 'logged_in' => true;
            redirect '/new-note';
        }
        else {
            redirect '/?err=1';
        };
    }
};

get '/register' => sub {
    template 'register' => { 
        'title' => 'Notes registration',
        'csrf_token' => get_csrf_token(),
         };
};

post '/register' => sub {
    my $username = body_parameters->get('username');
    my $password = md5_hex( body_parameters->get('password') );
    #TODO valid & escape
    my $valid_regexp =  qr/[A-Za-z_]{4,20}/;
    if ($username !~ $valid_regexp or length($password) < 4) {
        template 'register', {
            'title' => 'Notes registration',
            'err' => 'This username or rassword is too short or too long',
        };
    } elsif ($db->new_user($username, $password)) {
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

    my $notes = $db->get_notes($user_id);

    template 'new-note' => {
        'csrf_token' => get_csrf_token(),
        'title' => 'Atom notes',
        'username' => $username,
        'notes' => $notes,
    };

};

post '/new-note' => sub {
    my $username = session('username');
    my $user_id = session('user_id');
    my $title = body_parameters->get('title') || 'Untitled';
    my $text = body_parameters->get('text');
    my $sharing = body_parameters->get('share');

    if (!session('logged_in')) {
        # will ask to auth
        redirect '/';

    } elsif (!$text) {
         return template 'new-note' => { 
            'title' => 'Atom notes',
            'username' => $username,
            'err' => 'fill the \'text\' field',
        };
    } else {
        foreach my $input ($title, $text) {
            encode_entities($input, '<>&"')
        }

        my $time = time;
        my $note_id = '';
        my $try_count = 10;

        while ($try_count--) {
            $note_id = crc32 ($title.$time.$note_id);
            last if !$db->note_id_exists($note_id);
            if($try_count == 0) {
                die "wow!";
            }
        }

        my @sharingUsers = (split '\r\n', $sharing);
        
        my $errors = $db->new_note($note_id, $user_id, $time, $title, $text, \@sharingUsers);

        my $notes = $db->get_notes($user_id);

        redirect '/new-note';
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