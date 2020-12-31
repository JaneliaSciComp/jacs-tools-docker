#!/bin/bash
#
# Generates enchanced MIPs and movies for the input stack.
# Define TMPDIR before calling this script.
#

OUTPUT_DIR=$1
OUTPUT_PREFIX=$2
MODE=$3
INPUT_FILE=$4
CHAN_SPEC=$5
COLOR_SPEC=$6
OPTIONS=$7

# Start Xvfb
. /app/scripts/utils/initXvfb.sh

# Create temp dir so that large temporary avis are not created on the network drive
echo "Using $TMPDIR as temporary root"
mkdir -p $TMPDIR
TEMP_DIR=`mktemp -d`
function cleanTemp {
    rm -rf $TEMP_DIR
    echo "Cleaned up $TEMP_DIR"
}

# Two EXIT handlers
function exitHandler() { cleanXvfb; cleanTemp; }
trap exitHandler EXIT

# Run Fiji macro
echo "Executing:"
echo "/app/fiji/fiji -macro /app/fiji_macros/Enhanced_MIP_StackAvi.ijm $TEMP_DIR,$OUTPUT_PREFIX,$MODE,$INPUT_FILE,$CHAN_SPEC,$COLOR_SPEC,$OPTIONS > $OUTPUT_DIR/enhancedMIP.log 2>&1"
/app/fiji/fiji -macro /app/fiji_macros/Enhanced_MIP_StackAvi.ijm $TEMP_DIR,$OUTPUT_PREFIX,$MODE,$INPUT_FILE,$CHAN_SPEC,$COLOR_SPEC,$OPTIONS > $OUTPUT_DIR/enhancedMIP.log 2>&1 &

# Monitor Fiji and take periodic screenshots, killing it eventually
fpid=$!
. /app/scripts/utils/monitorXvfb.sh $PORT $fpid 3600

# Encode avi movies as mp4 and delete the input avi's
cd $TEMP_DIR
for fin in *.avi; do
    fout=${fin%.avi}.mp4
    ffmpeg -y -r 7 -i "$fin" -vcodec libx264 -b:v 2000000 -preset slow -tune film -pix_fmt yuv420p "$fout" \
        && rm $fin
done

# Move everything to the final output directory
cp $TEMP_DIR/*.png $OUTPUT_DIR || true
cp $TEMP_DIR/*.mp4 $OUTPUT_DIR || true

