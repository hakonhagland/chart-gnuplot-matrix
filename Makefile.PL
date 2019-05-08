use utf8;
use ExtUtils::MakeMaker;

WriteMakefile(
    ABSTRACT_FROM    => 'lib/Chart/Gnuplot/Matrix.pm',
    AUTHOR           => 'Håkon Hægland <hakon.hagland@gmail.com>',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => 5.016000,
    NAME             => 'Chart::Gnuplot::Matrix',
    PREREQ_PM        => {
        'ExtUtils::MakeMaker' => '7.12',
    },
    VERSION_FROM     => 'lib/Chart/Gnuplot/Matrix.pm',
);
