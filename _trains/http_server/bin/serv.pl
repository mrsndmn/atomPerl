use strict;
use warnings;

use feature 'say';
use DDP;
use Imager::File::JPEG;
use EV;
use AnyEvent::HTTP::Server;

my $s = AnyEvent::HTTP::Server->new(
	host => '0.0.0.0',
	port => 5000,
	cb => sub {
		my $request = shift;
		my $status  = 200;
		my $content = '<img src="/img.jpg" alt="альтернативный текст" width="800">';
		my $headers = { 'content-type' => 'text/html' };
		use DDP;
		p $request->[1];

		if($request->[1] eq "/img.jpg") {
			warn "in if";
			use FindBin;
			# open (my $fh, '<:raw', "$FindBin::Bin/../img.jpg");
			use Imager::File::JPEG;
			my $img;
			$img = Imager->new;
			$img->read(file=> "$FindBin::Bin/../img.jpg" , type=> "jpeg") or warn "cant open file";
			my $data;
			$img->write(type=>'jpeg', data=>\$data)
				or die $img->errstr;
	 
			$request->reply($status, $data, headers => { "content-type" => 'image/jpeg'});
			warn "after";
			# $fh->close()            
		} else {
			$request->reply($status, $content, headers => $headers);
		}
}
);
$s->listen;

$s->accept;

my $sig = AE::signal INT => sub {
warn "Stopping server";
$s->graceful(sub {
	warn "Server stopped";
	EV::unloop;
});
};

EV::loop;