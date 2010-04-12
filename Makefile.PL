use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Random::QRBG',
    AUTHOR              => 'BlueT - Matthew Lien - 練喆明 <BlueT@BlueT.org>',
    VERSION_FROM        => 'lib/Net/Random/QRBG.pm',
    ABSTRACT_FROM       => 'lib/Net/Random/QRBG.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'	=> 0,
		'common::sense'	=> 0,
		'Config'		=> 0,
		'IO::Socket::INET'	=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-Random-QRBG-*' },
);
