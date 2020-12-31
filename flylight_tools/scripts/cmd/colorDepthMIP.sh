#!/bin/bash
#
# Generate color depth MIPs for the given input stack.
#

OUTPUT_DIR=$1
INPUT_FILE=$2
ANATOMICAL_AREA=$3
MASK_DIR=$4

# Start Xvfb
. /app/scripts/utils/initXvfb.sh

# Create temp dir so that large temporary avis are not created on the network drive·
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

# The Fiji macro requires a trailing slash on the directory
INPUT_DIR=`dirname $INPUT_FILE`"/"
INPUT_FILENAME=`basename $INPUT_FILE`

# Run Fiji macro
echo "Executing:"
echo "/app/fiji/fiji -macro /app/fiji_macros/Color_Depth_MIP_batch_0724_2017_For_Pipeline.ijm $INPUT_DIR,$INPUT_FILENAME,$TEMP_DIR,$MASK_DIR,$ANATOMICAL_AREA > $OUTPUT_DIR/colorDepthMIP.log 2>&1"
/app/fiji/fiji -macro /app/fiji_macros/Color_Depth_MIP_batch_0724_2017_For_Pipeline.ijm $INPUT_DIR,$INPUT_FILENAME,$TEMP_DIR,$MASK_DIR,$ANATOMICAL_AREA > $OUTPUT_DIR/colorDepthMIP.log 2>&1 &

# Monitor Fiji and take periodic screenshots, killing it eventually
fpid=$!
. /app/scripts/utils/monitorXvfb.sh $PORT $fpid 3600

# Move everything to the final output directory
cp $TEMP_DIR/*.png $OUTPUT_DIR || true
cp $TEMP_DIR/*.properties $OUTPUT_DIR || true




