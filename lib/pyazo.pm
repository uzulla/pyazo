package pyazo;
use Dancer ':syntax';
use File::Slurp;
use Time::HiRes qw/ time /;
use String::Random;
use File::Basename;
use Image::Info;
use File::Path;
use Media::Type::Simple;
use LWP::UserAgent;
use Data::Dumper;

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
        if( !$type || $type eq '.com' ){ # .com will pass by mac gyazo client. wtf???
            my $img_info = Image::Info::image_type($upload->tempname); #画像データの一部から判定
            if ( $img_info->{error} ) {
                die sprintf("Can't determine file type: %s", $img_info->{error});
            }
            $type = '.'.$img_info->{file_type};
        }
        $filename = "image/" . randstr() . lc($type);
        $upload->copy_to( 'public/' . $filename);

    }elsif(upload('data')){ #gifzo mode
        unless($ENV{FFMPEG_PATH}){
            die "require FFMPEG_PATH env";
	    }
	    unless($ENV{IM_CONVERT_PATH}||$ENV{GIFSICLE_PATH}){
	        die "require IM_CONVERT_PATH or GIFSICLE_PATH env";
	    }

        $upload = upload('data');

        my $tmpdirname = String::Random->new->randregex('[A-Za-z0-9]{32}');
        my $tmpdirpath  = "tmp/".$tmpdirname;
        mkdir $tmpdirpath;

        my $movfilename = $upload->tempname;

        my $execline = "$ENV{FFMPEG_PATH} -i $movfilename -r 6 $tmpdirpath/%05d.gif";
        print $execline;
        `$execline`;

        my $outgif = "$tmpdirpath/out.gif";
        my $execline2;
        if($ENV{GIFSICLE_PATH}){
            $execline2 = "$ENV{GIFSICLE_PATH} --delay=10 --loop $tmpdirpath/*.gif > $outgif";    
        }elsif($ENV{IM_CONVERT_PATH}){
            $execline2 = "$ENV{IM_CONVERT_PATH} $tmpdirpath/*.gif $outgif";
        }else{
            die "require IM_CONVERT_PATH or GIFSICLE_PATH env";
        }
        print $execline2;
        `$execline2`;

        my $randstr = randstr();
        my $giffilename = "image/" . $randstr . ".gif";
        rename $outgif, 'public/' . $giffilename;
        my $mp4filename = "image/" . $randstr . ".mp4";
        $upload->copy_to( 'public/' . $mp4filename);

        File::Path::rmtree($tmpdirpath);

        $filename = $giffilename;

    }elsif( params->{fileurl} ){
        my $url = params->{fileurl};
        my $ua = LWP::UserAgent->new;
        my $r = $ua->head( $url );

        return 'error: HEAD request fail' unless $r; 

        my $size = $r->header('Content-Length');

        if( !$size || $size > (5*1024*1024) ){
            return 'error: request url too big (or get fail Content-Length)';
        }

        my $content_type = $r->header('Content-Type');
        my $ext = ext_from_type($content_type);
        $ext = ".$ext" if $ext;

        if(!$ext){
            my $_url = $url;
            $_url =~ s/#.*$//;
            $_url =~ s/^.*\///;
            my ($fn, $path, $type) = fileparse( $_url, qr/\.[^\.]+$/ );
            $ext = $type;
        }

        $filename = randstr() . $ext;

        $url = params->{fileurl};
        $r = $ua->mirror($url, 'public/image/'. $filename);
        return 'error: get fail' unless $r;

        $filename = 'image/'.$filename;

    }
    return 'error: blank post' unless $filename;

    return uri_for('/') . $filename;

};

get '/list' => sub { # experimental
    my @raw_file_list = glob("public/image/*");
   
    my $file_list = [];

    for my $filename (@raw_file_list) {
        my $type ;
        if( $filename =~ m/(jpg|jpeg|png|gif)$/i ){
            $type = 'image';
        }else{
            $type = 'other';
        }
        $filename =~ s|public/||g ;
        push( $file_list, {
                path => "../".$filename,
                type => $type,
            } );
        
    }

    my $html = '';
    for my $file (@$file_list){
        if($file->{type} eq "image"){
            $html.= "<img src='".$file->{path}."'><br>";
        }else{
            $html.= "<a href='".$file->{path}."'>".$file->{path}."</a><br>";
        }
    }
    return $html;
};

sub randstr{
    String::Random->new->randregex('[A-Za-z0-9]{16}') . Time::HiRes::time()*100000 ;
}

true;
