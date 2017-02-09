#/bin/bash
set -e

if [ -z "$3" ]; then
        echo "Not enough arguments."
        echo "Usage: $0 -i INPUT_FILE -o OUPTUT_FILE_NAME -d RESULT_DIR"
        exit 1
fi

INPUT=$1
OUTPUT=$2
RESULTDIR=$3

./fgenesb_2_cgview.pl --input $INPUT --output temp.xml
java -jar ./cgview.jar -i temp.xml -o $OUTPUT.png -f png -h $OUTPUT.html

cp $OUTPUT.png $RESULTDIR/
cp $OUTPUT.html $RESULTDIR/

#exec "$@"