package NotesWeb;
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
use ReadConf;
# use Devel::Peek;

my $confReader = ReadConf->new();
my $conf = $confReader->getConfig(); 
my $dbFile = $conf->{dbFile};
my $db = DBcommunication->new(dbFile => $dbFile);


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
        }

        my @sharingUsers = (split '\r\n', $sharing);
        
        my $errors = $db->new_note($note_id, $user_id, $time, $title, $text, \@sharingUsers);

        my $notes = $db->get_notes($user_id);

        # session 'notes' => $notes;
        # не знаю, зачем был это эксперимент, но соглашусь, это совершено неправильно
        template 'new-note' => { 
            'title' => 'Atom notes',
            'username' => $username,
            'notes' => $notes,
        };
        # redirect '/new-note';
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