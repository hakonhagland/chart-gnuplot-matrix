package Chart::Gnuplot::Matrix;
our $VERSION = 0.01;

=head1 NAME
  
Chart::Gnuplot::Matrix - Plot matrix using Gnuplot

=cut


use feature qw(say);
use strict;
use warnings;
use Exporter qw(import);
use Carp;
use File::Temp ();
our @EXPORT = ();
our @EXPORT_OK = ();

sub new {
    my ( $class, %args ) = @_;

    my $self = bless \%args, $class;
    $self->setup();
    return $self;
}

sub setup {
    my ( $self ) = @_;
    $self->setup_debug();
    $self->set_datax();
    $self->set_datay();
    $self->set_dataz();
    $self->set_xrotate();
    $self->set_xoffset();
    $self->set_xticks();
    $self->set_yticks();
    $self->set_persistent();
    $self->set_bottom_margin();
    $self->write_data_file();
    $self->write_script();
    my $args = $self->get_gnu_plot_args();
    system 'gnuplot', @$args;
}

sub set_datax {
    my ( $self ) = @_;

    if ( !(exists $self->{datax} ) ) {
        croak "No x-data given!";
    }

    $self->{datax} = get_data( $self->{datax} );
}

sub set_datay {
    my ( $self ) = @_;

    if ( !(exists $self->{datay} ) ) {
        croak "No y-data given!";
    }

    $self->{datay} = get_data( $self->{datay} );
}

sub set_dataz {
    my ( $self ) = @_;

    if ( !(exists $self->{datax} ) ) {
        croak "No x-data given!";
    }

    $self->{dataz} = get_data( $self->{dataz} );
}

sub get_data {
    my ( $data_or_fn ) = @_;
    
    if (ref $data_or_fn ) {
        return $data_or_fn;
    }
    else {
        my $fn = $data_or_fn;
        my @data;
        open ( my $fh, '<', $fn ) or die "Could not open file '$fn': $!";
        while (my $line = <$fh> ) {
            chomp $line;
            my @fields = split " ", $line;
            next if !@fields;
            if ( @fields == 1 ) {
                push @data, $fields[0];
            }
            else {
                push @data, \@fields;
            }
        }
        close $fh;
        return \@data;
    }
}

sub get_gnu_plot_args {
    my ( $self ) = @_;

    my @args = ();
    if ( $self->{persistent1} ) {
        push @args, $self->{persistent1};
        
    }
    push @args, $self->{script_fn};
    return \@args;
}

sub set_bottom_margin {
    my ( $self ) = @_;

    if ( !(exists $self->{bottom_margin} ) ) {
        $self->{bottom_margin} = 5;
    }
}

sub setup_debug {
    my ( $self ) = @_;

    if (! (exists $self->{debug}) ) {
        $self->{debug} = 0;
    }
}

sub set_yticks {
    my ( $self ) = @_;

    if ( !(exists $self->{yticks} ) ) {
        croak "Missing yticks!";
    }
    my $yticks = $self->{yticks};
    if (! (exists $yticks->{labels}) ) {
        croak "Missing ytick labels!";
    }
    my $labels = $yticks->{labels};
    $self->{yticks2} = '(' . (join ', ', @$labels ) . ')';
}

sub set_xticks {
    my ( $self ) = @_;

    if ( !(exists $self->{xticks} ) ) {
        croak "Missing xticks!";
    }
    my $xticks = $self->{xticks};
    if (! (exists $xticks->{labels}) ) {
        croak "Missing xtick labels!";
    }
    my $labels = $xticks->{labels};
    $self->{xticks2} = '(' . (join ', ', @$labels ) . ')';
}

sub set_xoffset {
    my ( $self ) = @_;

    if ( !(exists $self->{xticks} ) ) {
        croak "Missing xticks!";
    }
    my $xticks = $self->{xticks};
    if (! (exists $xticks->{offset}) ) {
        $self->{xoffset} = "0,-2.5";
    }
    else {
        $self->{xoffset} = $xticks->{offset};
    }
}

sub set_xrotate {
    my ( $self ) = @_;

    if ( !(exists $self->{xticks} ) ) {
        croak "Missing xticks!";
    }
    my $xticks = $self->{xticks};
    if (! (exists $xticks->{rotate}) ) {
        $self->{xrotate} = 0;
    }
    else {
        $self->{xrotate} = $xticks->{rotate};
    }
}

sub write_script {
    my ( $self ) = @_;

    ( my $fh, my $fn ) = $self->get_temp_file();

    my $template = ScriptTemplate->new(
        palette       => $self->{palette},
        xrotate       => $self->{xrotate},
        xoffset       => $self->{xoffset},
        xticks        => $self->{xticks2},
        yticks        => $self->{yticks2},
        persistent    => $self->{persistent2},
        bottom_margin => $self->{bottom_margin},
        output_file   => $self->{output},
        data_filename => $self->{data_fn},
    );
    
    print $fh $template->{template};
    close $fh;
    say "scriptfile: ", $fn if $self->{debug};
    $self->{script_fn} = $fn;
}

sub write_data_file {
    my ( $self ) = @_;

    ( my $fh, my $fn ) = $self->get_temp_file();

    my $num_rows = scalar @{ $self->{datay} };
    my $num_cols = scalar @{ $self->{datax} };
    my @x = 0..($num_cols - 1);
    my @y = 0..($num_rows - 1);
    say $fh join ' ', $num_cols, @x;
    for my $i (0..$#y) {
        say $fh join ' ', $y[$i], @{ $self->{dataz}[$i] };
    }
    close $fh;
    say "datafile: ", $fn if $self->{debug};
    $self->{data_fn} = $fn;
}

sub set_persistent {
    my ( $self ) = @_;
    if ( !( exists $self->{persistent} )) {
        $self->{persistent} = 0;
    }
    if( $self->{persistent} ) {
        $self->{persistent1} = '-p';
        $self->{persistent2} = '#';
    }
    else {
        $self->{persistent1} = '';
        $self->{persistent2} = '';
    }
}

sub get_temp_file {
    my ( $self ) = @_;
    
    my ( $fh, $temp_fn );
    eval { 
        ( $fh, $temp_fn ) = File::Temp::tempfile();
    };
    if ($@) {
        croak "Could not create temp file: $@";
    }
    return ( $fh, $temp_fn );
}

package ScriptTemplate;
use feature qw(say);
use strict;
use warnings;

use Carp;
use File::Temp ();

sub new {
    my ( $class, %args ) = @_;

    my $self = bless \%args, $class;
    $self->setup();
    return $self;
}

sub setup {
    my ( $self ) = @_;

    $self->{template} = get_template();
    my @template_keys =
      qw(
            palette xrotate xoffset xticks yticks persistent
            bottom_margin output_file data_filename
    );
    for my $key (@template_keys) {
        $self->add( $key )
    }
}


sub add {
    my ( $self,  $key_in ) = @_;

    my $key = uc $key_in;
    my $value = $key_in;
    $self->{template} =~ s/\[\[\Q$key\E\]\]/$self->{$value}/;
}

sub get_template {
    return q/
set autoscale xfix
set autoscale yfix
set autoscale cbfix
set palette [[PALETTE]]
set xtics rotate by [[XROTATE]] offset [[XOFFSET]] [[XTICKS]]
set ytics [[YTICKS]]
[[PERSISTENT]]set term png
set bmargin [[BOTTOM_MARGIN]]
set output "[[OUTPUT_FILE]]"
plot '[[DATA_FILENAME]]' matrix nonuniform with image notitle
  /;
}
