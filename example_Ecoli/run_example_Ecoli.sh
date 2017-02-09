#/bin/sh

../fgenesb_2_cgview.pl --input U00096.res --output U00096.xml

java -jar ../cgview.jar -i U00096.xml -o U00096.png   -f png -h U00096.html                     # complete map
java -jar ../cgview.jar -i U00096.xml -o U00096_1.png -f png -h U00096_1.html -z 100 -c 225000  # rRNA genes (LSU, SSU, 5S) + CDS
java -jar ../cgview.jar -i U00096.xml -o U00096_2.png -f png -h U00096_2.html -z 500 -c 695000  # cluster of tRNA genes     + CDS
