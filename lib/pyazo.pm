package pyazo;
use Dancer ':syntax';
use File::Slurp;
use Time::HiRes qw/ time /;
use String::Random;
use File::Basename;
use Image::Info;
use File::Path;

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
        $upload->copy_to( 'public/' . $filename);

    }elsif(upload('data')){ #gifzo mode
        $upload = upload('data');
        unless($ENV{FFMPEG_PATH} && $ENV{IM_CONVERT_PATH}){
            die "require IM_CONVERT_PATH and FFMPEG_PATH env";
        }

        my $tmpdirname = String::Random->new->randregex('[A-Za-z0-9]{32}');
        my $tmpdirpath  = "tmp/".$tmpdirname;
        mkdir $tmpdirpath;

        my $movfilename = $upload->tempname;

        my $execline = "$ENV{FFMPEG_PATH} -i $movfilename -r 6 $tmpdirpath/%05d.png";
        print $execline;
        `$execline`;

        my $outgif = "$tmpdirpath/out.gif";
        my $execline2 = "$ENV{IM_CONVERT_PATH} $tmpdirpath/*.png $outgif";
        print $execline2;
        `$execline2`;

        my $randstr = randstr();
        my $giffilename = "image/" . $randstr . ".gif";
        rename $outgif, 'public/' . $giffilename;
        my $mp4filename = "image/" . $randstr . ".mp4";
        $upload->copy_to( 'public/' . $mp4filename);

        File::Path::rmtree($tmpdirpath);

        $filename = $giffilename;

    }
    return uri_for('/') . $filename;

};

sub randstr{
    String::Random->new->randregex('[A-Za-z0-9]{16}') . Time::HiRes::time()*100000 ;
}

true;
