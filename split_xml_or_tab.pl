#!/usr/bin/perl -w
# Softberry Inc. 2008
# usage      :
#
# description:
#
# updated    : 
#
# version    : 1.00

use strict;
use IO::File;

if( @ARGV != 2 ) { help(); exit(1); }

my( $file, $format ) = @ARGV;

my $mark;  # records separator
my $mark_line;

if   ( $format =~ /^-xml$/ ) { $mark = '<\?xml'; }  # for .xml file
elsif( $format =~ /^-tab$/ ) { $mark = '#gi\|';  }  # for .tab file
else {
  help(); exit();
}

my( $base_name, $ext ) = $file =~ /^(.+)\.([^.]+)$/;

=pod

from .xml file:

<?xml version="1.0" encoding="ISO-8859-1"?>

from .tab file:

#gi|162623148|dbj|BAAW01000001.1| Human gut metagenome DNA, contig ...

=cut

my $file_iterator = generate_iterator__multiple_2_single_file( $file, $mark );

# put records in separate files
for( my $i=1;  &$file_iterator( "${base_name}_$i.$ext", \$mark_line ); $i++ ) {}

exit();

######################################################################

sub help {

print "
Usage: $0 <multi_file> -xml | -tab

Example:

$0 contigs.xml -xml

(if there are annotations for 10 contigs in 'contigs.xml', the command 
creates 10 files, with annotation for each contig in a separate file:

contigs_1.xml
contigs_2.xml
..
contigs_10.xml)

";

}

#--------------------------------------------------------------------#

=pod

# Examples how to use:

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
