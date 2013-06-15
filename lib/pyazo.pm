package pyazo;
use Dancer ':syntax';
use File::Slurp;
use Time::HiRes qw/ time /;
use String::Random;
use File::Basename;
use Image::Info;

use utf8;
binmode(STDOUT, ":utf8");
$|=1;

use Data::Dumper;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/' => sub {
    my $c = shift;

    my $filename;
    my $upload;
    if(upload('imagedata')){ #pyazo mode
        $upload = upload('imagedata');
        my ($fn, $path, $type) = fileparse( $upload->filename, qr/\.[^\.]+$/ );
        unless( $type ){
            my $img_info = Image::Info::image_type($upload->tempname); #画像データの一部から判定
            if ( $img_info->{error} ) {
                die sprintf("Can't determine file type: %s", $img_info->{error});
            }
            $type = '.'.$img_info->{file_type};
        }
        $filename = "image/" . randstr() . lc($type);

    }elsif(upload('data')){ #gifzo mode
        $upload = upload('data');
        $filename = "image/" . Time::HiRes::time() . ".mp4";

    }
    $upload->copy_to( 'public/' . $filename);
    return uri_for('/') . $filename;

};

sub randstr{
    String::Random->new->randregex('[A-Za-z0-9]{16}') . Time::HiRes::time()*100000 ;
}

true;
