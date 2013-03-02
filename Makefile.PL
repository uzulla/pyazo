use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'pyazo',
    AUTHOR              => q{uzulla <uzulla@himitsukichi.com>},
    VERSION_FROM        => 'lib/pyazo.pm',
    ABSTRACT            => 'pyazo',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3095,
        'File::Slurp' => 0,
        'Plack::Handler::Starman' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'pyazo-*' },
);
