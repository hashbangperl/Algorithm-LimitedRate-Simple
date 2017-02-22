use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Algorithm::LimitedRate::Simple',
    AUTHOR           => q{Aaron Trevena <teejay@cpan.org>},
    VERSION_FROM     => 'lib/Algorithm/LimitedRate/Simple.pm',
    ABSTRACT_FROM    => 'lib/Algorithm/LimitedRate/Simple.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
	Moose => 0,
	'Time::HiRes' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Algorithm-LimitedRate-Simple-*' },
);
