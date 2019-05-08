#! /usr/bin/env perl

use strict;
use warnings;
use Chart::Gnuplot::Matrix;

my $palette = 'defined (-12 "green",0 "gray",1.0625 "mediumpurple3",2.125 "purple",3.1875 "light-turquoise",4.25 "turquoise",5.3125 "dark-turquoise",6.375 "yellow",7.4375 "khaki",8.5 "dark-khaki",9.5625 "dark-goldenrod",10.625 "orange",11.6875 "orange-red",12.75 "red",13.8125 "dark-red",14.875 "brown",15.9375 "black")';

my @xtics = map {
    '"' . (sprintf "%02d:%02d", int(($_+1)/2), 30*(($_+1) % 2)) .'"' . " $_"
} 0..46;

my @ytics = map {
    '"' . (sprintf "%d-Oct", $_ + 1) . '"' . " $_"
} 0..30;

Chart::Gnuplot::Matrix->new(
    datax      => 'datax.txt',
    datay      => 'datay.txt',
    dataz      => 'dataz.txt',
    palette    => $palette,
    persistent => 1,
    output     => 'heat.png',
    xticks      => {
        labels => \@xtics,
        rotate => 90,
    },
    yticks      => {
        labels   => \@ytics,
    },
    debug      => 0,
);

