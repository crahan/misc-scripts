#!/bin/sh
#
# Dumps a directory with rrd xml files to xml format
# $1: the folder containing the rrd files
# $2: (optional) the output folder where to save the rrd files
#
if [ "$2" = "" ]; then
 dname=$1
else
 dname=$2
fi

for f in `ls $1/*.rrd`
do
 fname=$(basename $f)
 fname=${fname%.*}
 echo "Dumping $fname.rrd"
 # convert to xml format
 rrdtool dump "$f" > "$dname/$fname.xml" 
done
