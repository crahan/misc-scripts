#!/bin/sh

# wait before taking screenshot
# idle="10" 

# preferred filename
fname=`date +%Y%m%d_%H%M%S`

# where to save the screenshot
saveto="./"

# filename extension (png|jpg|eps)
ext="png" 

# uncomment these values if you want to add a watermark
# overlay="watermark.png"
# dissolve="25"

#----------------
# check commands
#----------------
if ! which screencapture >/dev/null && \ 
   ! which composite > /dev/null && \
   ! which sips > /dev/null; then
    echo "Could not find gfx tools, exiting."
    exit 1
fi

#--------------
# help message
#--------------
function printhelp {
    cat <<END_HELP
Grabs a screenshot and watermarks it.	
-w   wait n seconds before taking the screenshot 
-f   save as filename
-l   local directory to save screenshot
-o   overlay/watermark image
-d   amount to dissolve the overlay (%)
-t   screenshot file type (png|jpg|eps)
END_HELP
}

#---------------
# usage message
#---------------
function printusage {
    echo "Usage: screenshot.sh [ OPTION1 OPTION2 ... ]"
}

#------------------
# check parameters
#------------------
while getopts ":w:f:l:o:d:t:h" options; do
    case $options in
        w ) idle=$OPTARG;;
        f ) fname=$OPTARG;;
        l ) saveto=$OPTARG;;
        o ) overlay=$OPTARG;;
        d ) dissolve=$OPTARG;;
        t ) ext=$OPTARG;;
        h ) printusage
            printhelp
            exit 0;;
       \? ) printusage
            exit 1;;	
        * ) printusage
            exit 1;;
    esac
done

#--------------
# set defaults 
#--------------
idle=${idle:-0}
fname=${fname:-screenshot}
sleep $idle
mkdir /tmp/shots 2>/dev/null

#-----------------
# take screenshot
#-----------------
echo -n "Taking screenshot..."
screencapture /tmp/shots/ss.pdf
echo "done."
echo -n "Converting to $ext..."
sips -s format $ext /tmp/shots/ss.pdf --out /tmp/shots/ss.$ext > /dev/null 2>&1
echo "done."

#---------------
# add watermark 
#---------------
if [ $overlay ]; then
    echo -n "Applying watermark..."
    if [ -e $overlay ]; then		
        composite -dissolve $dissolve -gravity SouthEast -geometry +25+25 $overlay /tmp/shots/ss.$ext /tmp/shots/$fname.$ext
        echo "done."
    else
        echo "not found."
        mv /tmp/shots/ss.$ext  /tmp/shots/$fname.$ext
    fi
else
    # no watermark specified so just rename the file
    mv /tmp/shots/ss.$ext /tmp/shots/$fname.$ext
fi

#----------------
# save & clean up
#----------------
cp /tmp/shots/$fname.$ext $saveto/
rm -rf /tmp/shots

