#/bin/sh

../fgenesb_2_cgview.pl --input NC_000854.res --output NC_000854.xml

java -jar ../cgview.jar -i NC_000854.xml -o NC_000854.png   -f png -h NC_000854.html
java -jar ../cgview.jar -i NC_000854.xml -o NC_000854_1.png -f png -h NC_000854_1.html -z 36 -c 1220000

