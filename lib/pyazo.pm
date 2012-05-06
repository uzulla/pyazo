package pyazo;
use Dancer ':syntax';
use File::Slurp;
use Digest::MD5 qw( md5_hex );

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/' => sub {
    my $c = shift;
    my $imagedata = upload('imagedata')->content;
    my $filename = "image/" . md5_hex($imagedata) . ".png";
    write_file('../public/'.$filename, {binmode => ':raw'}, $imagedata);
    my $url = uri_for('/') . $filename;
    return $url;
};

true;
