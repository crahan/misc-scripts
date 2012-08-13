#!/bin/sh
#
# resizes a set of images in folder A and saves them in folder B.
# $1: the folder containing the original files
# $2: (optional) the output folder where to save the resized files
# $3: (optional) width and height specified, default 200x200
#

# set the output path variable
if [ "$2" = "" ]; then
 dname="$1/resized"
else
 dname=$2
fi

if [ "$3" = "" ]; then
 outputsize="200x200"
else
 outputsize=$3
fi

# create the output directory if it doesn't exist
if [ ! -d "$dname" ]; then
    mkdir -p $dname
fi

# resize
for f in `ls $1/*`
do
 fname=$(basename $f)
 #fname=${fname%.*}
 echo "Converting $fname"
 # resize and pad the images
 convert $1/$fname -thumbnail "$outputsize>" -background white -gravity center -extent $outputsize $dname/$fname
 # -define jpeg:size=$outputsize
done
