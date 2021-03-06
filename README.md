Instruction:
how to visualize Fgenesb predictions with CGView
------------------------------------------------

Script "fgenesb_2_cgview.pl" (Softberry Inc., 2008)

CGView is a third party software developed by:
Stothard P, Wishart DS. Circular genome visualization and exploration using CGView. Bioinformatics 21:537-539.


RUN IN DOCKER
=============
Get the respository from Github: 

```
git clone https://github.com/solovictor/Fgenesb_CGView.git
cd Fgenesb_CGView
```

```
# Build a contaier
docker build -t cgview  .

# Run container to show the usage
docker run -it -v /vagrant/share:/share:rw --rm  cgview
Not enough arguments.
Usage: /Fgenesb_CGView/run.sh -i INPUT_FILE -o OUPTUT_FILE_NAME -d RESULT_DIR

# Run container
docker run -it -v /vagrant/share:/share:rw --rm  cgview /share/result.result output1 /share
```
Explanations:

* `-v /vagrant/share:/share` - maps the host directory to container, so that we can
  get the results from container.
* `cgiview` - image name
* `/share/result.result` - result of fgenesb computations, full path
* `output` - name of output file, without extension, will produce `.png` and `.html`
* `/share` - path to shared storate inside a container, to place resulting images.

CONTENT
=======

fgenesb_2_cgview.pl - converter from Fgenesb to cgview xml format
split_xml_or_tab.pl - script to split multiple XML file
cgview.jar          - CGView application (requires Java 1.5 or higher!)
lib                 - directory with java libs

Examples:

example_Ecoli/        - how to generate images with predictions for E.coli
example_Ecoli_linked/ - how to generate linked images for E.coli
example_Apernix/      - how to generate images with predictions for A.pernix
example_test_seq/     - how to generate an image for a test sequence

See and run appropriate shell scripts from these directories:

./run_example_Ecoli.sh
./run_example_Ecoli_linked.sh
./run_example_Apernix.sh
./run_example_test_seq.sh

('U00096.res' and 'NC_000854.res' - Fgenesb annotations for E.coli and A.pernix)


COMMANDS TO RUN
===============

COMMAND 1
---------

convert Fgenesb annotation to XML file for CGView

./fgenesb_2_cgview.pl --input <fgenesb_file> --output <xml_file> [more options]


Examples:

a) ./fgenesb_2_cgview.pl --input NC_000854.res --output NC_000854.xml

  display all features:

    CDS       - protein coding genes
    LSU_RRNA  - rRNA genes for large subunit
    SSU_RRNA  - rRNA genes for small subunit
    5S_RRNA   - rRNA genes for  5S   subunit
    TRNA      - tRNA genes
    Prom      - Promoters
    Term      - Terminators

  show genes on different levels according to their frames


b) ./fgenesb_2_cgview.pl --input NC_000854.res --output NC_000854.xml --noframes

  show genes on 2 levels, as forward and reverse genes (no frames)


c) ./fgenesb_2_cgview.pl --input NC_000854.res --output NC_000854.xml --exclude Prom,Term

  do not display features 'Prom', 'Term' (promoters and terminators)


d) ./fgenesb_2_cgview.pl --input NC_000854.res --output NC_000854.xml --feature CDS

  display only protein-coding genes (feature 'CDS')


e) ./fgenesb_2_cgview.pl --help

  get help (see also APPENDIX 1)


COMMAND 2
---------

visualize predictions with CGView (run cgview.jar)

a) create a series of linked images:

   java -jar cgview.jar -i <xml_file> -s <directory>  >  <log_file>

   open file <directory>/index.html in web browser

b) create one image (zoomed and centered around some base):

   java -jar cgview.jar -i <xml_file> -o <png_file> -f png -h <html_file> -z <zoom> -c <center>

   open file <png_file> in some picture viewer or <html_file> in web browser

c) create one image with all genes (a complete map):

   java -jar cgview.jar -i <xml_file> -o <png_file> -f png -h <html_file>

   open file <png_file> in some picture viewer or <html_file> in web browser


Examples:

a) java -jar cgview.jar -i NC_000854.xml -s Apernix_K1  >  NC_000854.log

   with option -s creates a series of linked images in the directory 'Apernix_K1/'

   open file 'Apernix_K1/index.html' in web browser

b) java -jar cgview.jar -i NC_000854.xml -o NC_000854_1.png -f png -h NC_000854_1.html -z 36 -c 1220000

   create a single image, zoomed (x 36) and centered around position 1220000

   open file 'NC_000854_1.png' in some picture viewer or 'NC_000854_1.html' in web browser

c) java -jar cgview.jar -i NC_000854.xml -o NC_000854.png -f png -h NC_000854.html

   create a single image with all genes predicted

   open file 'NC_000854.png' in some picture viewer or 'NC_000854.html' in web browser


NOTE (multiple vs. single images):
----

It takes some time and disk space to create a series of images for a genome,
but then it is easy and convenient to navigate through the generated map.

For example, >2000 images are generated by default for A.pernix or E.coli
(if -s option is used) - see the table below.

genome                              Aeropyrum pernix K1, RefSeq: NC_000854
genome length, bp                   1669695
Fgenesb predicted genes             1842
size of Fgenesb annotation file     1.4 Mb
images generated with option -s     >2000 files, ~137 Mb

genome                              Escherichia coli K12 MG1655, GenBank: U00096
genome length, bp                   4639675
Fgenesb predicted genes             4342
size of Fgenesb annotation file     4 Mb
images generated with option -s     >2000 files, ~205 Mb


On the other hand, it is very fast to create single images, for example,
for tests (before starting to create multiple images) - to choose parameters,
features and how to display them, or for presentations (using different zoom
factors and other options).

More options for CGView program (cgview.jar) see at the page -
http://wishart.biology.ualberta.ca/cgview/application.html


MORE EXAMPLES for E.coli
------------------------

try combinations of commands (1 and 2) for E.coli

(command 1)

./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --feature CDS
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --exclude Prom,Term
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --noframes
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --exclude Prom,Term --noframes

(command 2)

java -jar cgview.jar -i U00096.xml -o U00096_1.png -f png -h U00096_1.html -z 100 -c 225000  # rRNA genes (LSU, SSU, 5S) + CDS
java -jar cgview.jar -i U00096.xml -o U00096_2.png -f png -h U00096_2.html -z 500 -c 695000  # cluster of tRNA genes     + CDS


To view a complete map of genes:

java -jar cgview.jar -i U00096.xml -o U00096.png   -f png -h U00096.html  # all genes


To generate a series of linked images:

java -jar cgview.jar -i U00096.xml -s Ecoli_K12  >  U00096.log


NOTE (for files with Fgenesb annotations of multiple contigs):
----

For a file with multiple FgenesB annotations, 'fgenesb_2_cgview.pl' creates
a file with multiple XML entries. But 'cgview.jar' does not like multiple
XML in one file. Script 'split_xml_or_tab.pl' can be used to split multiple
XML file into many files, and 'cgview.jar' can be run on them one by one.

(see also APPENDIX 2)


DESCRIPTION OF IMAGES
=====================

The following features can be displayed on generated images:

    CDS       - protein coding genes
    LSU_RRNA  - rRNA genes for large subunit
    SSU_RRNA  - rRNA genes for small subunit
    5S_RRNA   - rRNA genes for  5S   subunit
    TRNA      - tRNA genes
    Prom      - Promoters
    Term      - Terminators

Genes, promoters and terminators are marked as arrows.
The contents of the feature rings (starting with the outermost ring) are as
follows.

(if genes are shown according to their frames)

Ring 1: forward strand features 'Prom' and 'Term'.
Rings 2,3,4: forward strand ORFs in reading frames 3,2,1.
Rings 5,6,7: reverse strand ORFs in reading frames 1,2,3.
Ring 8: reverse strand features 'Prom' and 'Term'.

(if genes are shown as forward and reverse genes, with --noframes option)

Ring 1: forward strand features 'Prom' and 'Term'.
Ring 2: forward strand ORFs.
Ring 3: reverse strand ORFs.
Ring 4: reverse strand features 'Prom' and 'Term'.


Use buttons or click on grey marks to navigate through a map (series of linked
images). Pointing to feature labels by mouse gives some info like gene names,
COG numbers (if annotated), scores (for promoters and terminators).

More info about CGView -
http://wishart.biology.ualberta.ca/cgview/

----------------------------------------------------------------------

APPENDIX 1 (script 'fgenesb_2_cgview.pl')
=========================================

Usage: ./fgenesb_2_cgview.pl --input <fgenesb_file> [options]

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

./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --feature CDS
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --exclude Prom,Term
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --noframes
./fgenesb_2_cgview.pl --input U00096.res --output U00096.xml --exclude Prom,Term --noframes
./fgenesb_2_cgview.pl --input U00096.res --output U00096.tab --format tab


APPENDIX 2 (script 'split_xml_or_tab.pl')
=========================================

Usage: ./split_xml_or_tab.pl <multi_file> -xml | -tab

Example:

./split_xml_or_tab.pl contigs.xml -xml

(if there are annotations for 10 contigs in 'contigs.xml', the command
creates 10 files, with annotation for each contig in a separate file:

contigs_1.xml
contigs_2.xml
..
contigs_10.xml)

----------------------------------------------------------------------

