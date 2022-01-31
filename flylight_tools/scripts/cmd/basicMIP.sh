#!/bin/bash
#
# Generates basic MIPs and movies for input stacks.
# Define TMPDIR before calling this script.
#

OUTPUT_DIR=$1
OUTPUT_PREFIX_1=$2
OUTPUT_PREFIX_2=$3
INPUT_FILE1=$4
INPUT_FILE2=$5
LASER=$6
GAIN=$7
CHAN_SPEC=$8
COLOR_SPEC=$9
DIV_SPEC=${10}
OPTIONS=${11}

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
echo "/app/fiji/fiji -macro /app/fiji_macros/Basic_MIP_StackAvi.ijm $TEMP_DIR,$OUTPUT_PREFIX_1,$OUTPUT_PREFIX_2,$INPUT_FILE1,$INPUT_FILE2,$LASER,$GAIN,$CHAN_SPEC,$COLOR_SPEC,$DIV_SPEC,$OPTIONS > $OUTPUT_DIR/basicMIP.log 2>&1"
/app/fiji/fiji -macro /app/fiji_macros/Basic_MIP_StackAvi.ijm $TEMP_DIR,$OUTPUT_PREFIX_1,$OUTPUT_PREFIX_2,$INPUT_FILE1,$INPUT_FILE2,$LASER,$GAIN,$CHAN_SPEC,$COLOR_SPEC,$DIV_SPEC,$OPTIONS > $OUTPUT_DIR/basicMIP.log 2>&1 &

# Monitor Fiji and take periodic screenshots, killing it eventually
fpid=$!
. /app/scripts/utils/monitorXvfb.sh $PORT $fpid 3600

# Encode avi movies as mp4 and delete the input avi's
cd $TEMP_DIR
for fin in *.avi; do
    fout=${fin%.avi}.mp4
    /app/ffmpeg/ffmpeg -y -r 7 -i "$fin" -vcodec libx264 -b:v 2000000 -preset slow -tune film -pix_fmt yuv420p "$fout" \
        && rm $fin
done

# Move everything to the final output directory
cp $TEMP_DIR/*.png $OUTPUT_DIR || true
cp $TEMP_DIR/*.mp4 $OUTPUT_DIR || true
cp $TEMP_DIR/*.properties $OUTPUT_DIR || true

