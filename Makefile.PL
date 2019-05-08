use utf8;
use ExtUtils::MakeMaker;

WriteMakefile(
    MIN_PERL_VERSION => 5.016000,
    NAME             => 'Chart::Gnuplot::Matrix',
    VERSION_FROM     => 'lib/Chart/Gnuplot/Matrix.pm',
    PREREQ_PM        => { 'ExtUtils::MakeMaker' => '7.12' },
    ABSTRACT_FROM    => 'lib/Chart/Gnuplot/Matrix.pm',
    AUTHOR           => 'Håkon Hægland <hakon.hagland@gmail.com>',
    LICENSE          => 'perl',
);
