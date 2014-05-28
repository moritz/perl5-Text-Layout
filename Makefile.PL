use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::PageLayout',
    AUTHOR              => q{Moritz Lenz <moritz@faui2k3.org>},
    VERSION_FROM        => 'lib/Text/PageLayout.pm',
    ABSTRACT_FROM       => 'lib/Text/PageLayout.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-PageLayout-*' },
);
