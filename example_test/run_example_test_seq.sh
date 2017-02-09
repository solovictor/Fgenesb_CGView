#/bin/sh

../fgenesb_2_cgview.pl --input test.res --output test.xml

java -jar ../cgview.jar -i test.xml -o test.png -f png -h test.html

