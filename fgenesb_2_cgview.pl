#!/usr/bin/perl -w
#
# usage      :
#
# description:
#
# updated    : 19.09.2012 (works with multi-FgenesB format)
#
# version    : 1.03

use strict;

use IO::File;
use Getopt::Long;
use Data::Dumper;

use File::Temp qw( tempfile );

#--------------------------------------------------------------------#

if( !@ARGV ) { help(); exit(); }

my( $fgenesb_file, $output, $help, $feature, $noframes, $exclude, $format );

my $result = GetOptions (
                         "input=s"   => \$fgenesb_file,
                         "output=s"  => \$output,
                         "help"      => \$help,
                         "noframes"  => \$noframes,
                         "feature=s" => \$feature,
                         "exclude=s" => \$exclude,
                         "format=s"  => \$format,
                        );

if( $help ) { help(); exit(); }

die "Input file is not defined\n" unless    $fgenesb_file;
die "Input file does not exist\n" unless -f $fgenesb_file;

$format = "xml" unless $format;

die "Bad format value\n" if $format ne "xml" && $format ne "tab";


my @features = ( 'CDS', 'LSU_RRNA', 'SSU_RRNA', '5S_RRNA', 'TRNA', 'Prom', 'Term' );

my $color = {
  'CDS'      => 'red',
  'LSU_RRNA' => 'blue',
  'SSU_RRNA' => 'orange',
  '5S_RRNA'  => 'aqua',
  'TRNA'     => 'green',
  'Prom'     => 'purple',
  'Term'     => 'black'
};

#--------------------------------------------------------------------#

my %display;  # features to visualize

if( !$feature || $feature =~ /^all$/i ) {
  @display{ @features } = ( 1 ) x scalar @features;
}
else {
  foreach (split(/,\s?/,$feature)) {
    if( exists( $color->{ $_ } )) { $display{ $_ } = 1; }
  # wrong feature
    else { help(); exit(); }
  }
}

if( $exclude ) {
  if( $feature ) { die "error: --feature and --exclude cannot be used together"; }

  foreach( split( /,\s?/, $exclude )) {
    if( exists( $color->{ $_ } )) { delete $display{ $_ }; }
  # wrong feature
    else { help(); exit(); }
  }
}

my $regexp = join('|',keys %display);

#--------------------------------------------------------------------#

# tmp files
my( $fh, $single_fgenesb ) = tempfile( "${fgenesb_file}_XXXX" ); $fh->close();

my $fw;

if( defined $output ) {

  $fw = new IO::File;

  $fw->open( ">$output" ) || die "can't open file $output: $!";
}

my $first_line;

my $fgenesb_iterator = generate_iterator__multiple_2_single_file( $fgenesb_file, ' Prediction of potential genes' );

# iteration through fgenesb records
while( &$fgenesb_iterator( $single_fgenesb, \$first_line )) {


my $p; # parser
my $genes_section;

my $fr = new IO::File;

$fr->open( "<$single_fgenesb" ) || die $!;

while( <$fr> ) {
  chomp;
  if( /Length of sequence - (\d+) bp/ ) {
    $p->{len} = $1;
    next;
  }
  if( /Seq name: (.*)/ ) {
    $p->{seq_name} = $1;
    next;
  }
  if( /^.*([+-])\s+(TRNA|5S_RRNA|Prom|Term|CDS|SSU_RRNA|LSU_RRNA)\s+(\d+)\s+-\s+(\d+)\s+([-\d\.]+)\s*#?#?\s?(.*)$/ ) {
    $genes_section = 1;
    my ($strand,$name,$start,$end,$score,$desc) = ($1,$2,$3,$4,$5,$6);

    if( $name =~ /^$regexp$/ ) {

      $desc =~ s/[^\w\s\-.?+:;,\[\]\{\}\(\)]//g if $desc; #\r\f\b\a\e\033\x1b\x{263a}\c[]
      $desc .= " Score: $score";

    # Prom, Term -> 4th level
      if( $name eq "Term" || $name eq "Prom" ) {
      	my $level = $noframes ? 2 : 4;
        push @{$p->{$strand}->{$level}->{$name}}, [$start,$end,$score,$desc];
      }

    # CDS, SSU_RRNA, LSU_RRNA, 5S_RRNA, TRNA
      else {

        my( $frame, $level );

        if( $strand eq '+' ) {
          $frame = $start % 3;
          $frame = 3 if $frame == 0;
        }
        else {
          $frame = ( $p->{len} - $end + 1 ) % 3;
          $frame = 3 if $frame == 0;
          $frame = -$frame;
        }
        $level = $noframes ? 1 : abs( $frame );

        push @{$p->{$strand}->{$level}->{$name}}, [$start,$end,$score,$desc];
      }
    }
    next;
  }
  elsif( $genes_section ) {
    last;
  }
}

$fr->close();

#--------------------------------------------------------------------#

my $out;

if( $format eq "xml" ) {

  my %strand = ("+"=>"direct",
                "-"=>"reverse");

$out = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
$out .= "<cgview backboneRadius=\"200\" sequenceLength=\"$p->{len}\" height=\"700\" width=\"700\" titleFont=\"SansSerif, plain, 18\" title=\"Length\" globalLabel=\"auto\" moveInnerLabelsToOuter=\"false\" featureThickness=\"xx-large\" tickLength=\"small\" shortTickColor=\"gray\" longTickColor=\"gray\" zeroTickColor=\"gray\" showBorder=\"false\">\n\n";

$out .= "<legend position=\"upper-center\" backgroundOpacity=\"0.8\">
  <legendItem textAlignment=\"center\" font=\"SansSerif, plain, 16\" text=\"$p->{seq_name}\" />
</legend>\n\n";

$out .= "<legend position=\"upper-right\" font=\"SanSerif, plain, 10\" backgroundOpacity=\"0.8\">\n";
$out .= "  <legendItem text=\"Features\" font=\"SanSerif, plain, 12\" />\n";

foreach( @features ) {
  next unless exists $display{ $_ };
  $out .= "  <legendItem text=\"$_\" drawSwatch=\"true\" swatchColor=\"$color->{$_}\" />\n";
}
$out .= "</legend>\n\n";

foreach my $strand (keys %strand) {
  foreach my $level (sort keys %{$p->{$strand}}) {
    $out .= "<featureSlot strand=\"$strand{$strand}\">\n";
    foreach my $name (keys %{$p->{$strand}->{$level}}) {
      my $decoration = ($strand eq "+")?("clockwise-arrow"):("counterclockwise-arrow");
      $out .= "  <feature color=\"$color->{$name}\" decoration=\"$decoration\" label=\"$name\">\n";
      foreach my $a (@{$p->{$strand}->{$level}->{$name}}) {
        $out .= "    <featureRange start=\"$a->[0]\" stop=\"$a->[1]\" mouseover=\"$a->[3]\" />\n";
      }
      $out .= "  </feature>\n";
    }
    $out .= "</featureSlot>\n\n";
  }
}

$out .= "</cgview>\n";
}

#---------------------------------------------------------------------

# tab delimited format
else {

my %strand = ("+"=>"forward",
              "-"=>"reverse");
my %name = (
        'CDS'      => 'predicted_gene',
        'LSU_RRNA' => 'gene',
        'SSU_RRNA' => 'gene',
        '5S_RRNA'  => 'gene',
        'TRNA'     => 'gene',
        'Prom'     => 'promoter',
        'Term'     => 'terminator',
);

$out  = "#$p->{seq_name}\n";
$out .= "\%$p->{len}\n";
$out .= "!strand	slot	start	stop	type	 label	mouseover	hyperlink\n";

foreach my $strand (keys %strand) {
  foreach my $level (sort keys %{$p->{$strand}}) {
    foreach my $name (keys %{$p->{$strand}->{$level}}) {
      foreach my $a (@{$p->{$strand}->{$level}->{$name}}) {
        $a->[3] = "-" unless $a->[3];
        $out .= "$strand{$strand}	$level	$a->[0]	$a->[1]	$name{$name}	$name	$a->[3]	-\n";
      }
    }
  }
}

}

#--------------------------------------------------------------------#

if( defined $output ) { print $fw $out; }  # print to file
else                  { print     $out; }  # print to standard output

}  #! $fgenesb_iterator


if( defined $output ) { $fw->close() || die "can't close file $output: $!"; }

# delete tmp files
unlink $single_fgenesb;


######################################################################

sub help {

print "Usage: $0 --input <fgenesb_file> [options]

  <fgenesb_file> - file with Fgenesb annotation

   [options]:

  --output <xml_file> - output xml file

               if this option is not provided,
               generated xml file is printed to standard output

  --feature  - list of features for visualization
               (separated by comma if more than 1)

    CDS       (protein coding genes)
    LSU_RRNA  (rRNA genes for large subunit)
    SSU_RRNA  (rRNA genes for small subunit)
    5S_RRNA   (rRNA genes for  5S   subunit)
    TRNA      (tRNA genes)
    Prom      (Promoters)
    Term      (Terminators)

               by default, all the features are visualized

  --exclude  - list of features not to visualize
               (separated by comma if more than 1)

               cannot be used together with --feature option

  --noframes - do not split genes into frames,
               show them just as forward and reverse genes

               by default, genes are shown in 6 frames

  --format   - output format type, format may be either 'xml' or 'tab'

    xml (default) http://wishart.biology.ualberta.ca/cgview/xml_overview.html
    tab           http://wishart.biology.ualberta.ca/cgview/tab_input.html

  --help     - print help and exit


Examples:

$0 --input U00096.ann --output U00096.xml
$0 --input U00096.ann --output U00096.xml --feature CDS
$0 --input U00096.ann --output U00096.xml --exclude Prom,Term
$0 --input U00096.ann --output U00096.xml --noframes
$0 --input U00096.ann --output U00096.xml --exclude Prom,Term --noframes
$0 --input U00096.ann --output U00096.tab --format tab

";
}

#--------------------------------------------------------------------#

=pod

# Examples how to use:

# (for FgenesB output)

my $fgenesb_iterator = generate_iterator__multiple_2_single_file( $fgenesb_file, ' Prediction of potential genes' );

while( &$fgenesb_iterator( $single_fgenesb, \$first_line )) {
  next fgenesb is in $single_fgenesb file
}

# (for multiple FASTA)

my $seq_iterator = generate_iterator__multiple_2_single_file( $seq_file, '>' );

while( &$seq_iterator( $single_fasta, \$defline )) {
  next seq. is in file $single_fasta
}

=cut

sub generate_iterator__multiple_2_single_file {

  my( $multi_file, $mark ) = @_;

  my $fh = new IO::File;

     $fh->open( "<$multi_file" ) || die "can't open file $multi_file: $!";

  my $defline;  # defline starts new item, it is an items separator line

# closure uses $fh, $defline variables from environment

  my $rs = sub {

             my( $single_file, $r_defline ) = @_;

             if( $fh->eof ) { $fh->close; return 0; }

             if( !defined $defline ) { $defline = <$fh> }  # 1st defline

             chomp( $$r_defline = $defline );

             local *I;

             open  I, ">$single_file";
             print I $defline;

             while( <$fh> ) {
               if( /^$mark/ ) {  # mark of separator line
                 $defline = $_;
                 last;
               }
               print I;
             }

             close I;

             return 1;
           };

  return $rs;
}

#--------------------------------------------------------------------#
