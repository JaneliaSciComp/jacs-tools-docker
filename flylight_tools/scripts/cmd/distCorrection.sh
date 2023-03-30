#!/bin/bash
#
# Calls Fiji to apply distortion correction to the input LSM image.
#

LSM_FILENAME=$1
DC_FILENAME=$2
MICROSCOPE=$3
OBJECTIVE=$4
DIMX=$5
CAPTURE_DATE=$6
DIST_JSON_DIR=$7

echo "Processing input image $LSM_FILENAME"
echo "Will output corrected image to $DC_FILENAME"

# Start Xvfb
. /app/scripts/utils/initXvfb.sh

# Create temp dir so that large temporary files are not created on the network drive·
echo "Using $TMPDIR as temporary root"
mkdir -p $TMPDIR
TEMP_DIR=`mktemp -d`"/"
function cleanTemp {
    rm -rf $TEMP_DIR
    echo "Cleaned up $TEMP_DIR"
}

# Two EXIT handlers
function exitHandler() { cleanXvfb; cleanTemp; }
trap exitHandler EXIT

# Get directory locations off the file full paths
IN_DIR=`dirname $LSM_FILENAME`
IN_FNAME=`basename $LSM_FILENAME`
OUT_DIR=$TEMP_DIR
FINAL_DIR=`dirname $DC_FILENAME`

# Run Fiji macro
echo "Executing:"
echo "/app/fiji/fiji -macro /app/fiji_macros/Chromatic_aberration_pipeline.ijm \"$IN_DIR/,$IN_FNAME,$OUT_DIR,$MICROSCOPE,$OBJECTIVE,$CAPTURE_DATE,$DIMX,$DIST_JSON_DIR\""
/app/fiji/fiji -macro /app/fiji_macros/Chromatic_aberration_pipeline.ijm "$IN_DIR/,$IN_FNAME,$OUT_DIR,$MICROSCOPE,$OBJECTIVE,$CAPTURE_DATE,$DIMX,$DIST_JSON_DIR" > $OUT_DIR/Fiji_Output_${IN_FNAME}.log 2>&1 &

# Monitor Fiji and take periodic screenshots, killing it eventually
fpid=$!
. /app/scripts/utils/monitorXvfb.sh $PORT $fpid 3600

echo "Temporary outputs:"
ls -l $OUT_DIR

# Save the log files
echo "Saving log files"
cp $OUT_DIR/Distortion_Correction*${IN_FNAME}.txt .
cp $OUT_DIR/Fiji_Output_${IN_FNAME}.log .

# Save the final outputs
echo "Moving outputs to $FINAL_DIR"
cp $OUT_DIR/*.v3draw $FINAL_DIR

echo "Done"
