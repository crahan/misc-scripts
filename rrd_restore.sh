#!/bin/sh
#
# Restores a directory with dumped rrd xml files back to rrd format
# $1: the folder containing the xml files
# $2: (optional) the output folder where to save the rrd files
#
if [ "$2" = "" ]; then
 dname=$1
else
 dname=$2
fi

for f in `ls $1/*.xml`
do
 fname=$(basename $f)
 fname=${fname%.*}
 echo "Restoring $fname.xml"
 # convert to rrd format
 rrdtool restore "$f" "$dname/$fname.rrd" 
done
