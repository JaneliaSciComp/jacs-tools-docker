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

# Start Xvfb
. /app/scripts/utils/initXvfb.sh

# Get directory locations off the file full paths.
IN_DIR=`dirname $LSM_FILENAME`
OUT_DIR=`dirname $DC_FILENAME`
IN_FNAME=`basename $LSM_FILENAME`

# Run Fiji macro
echo "Executing:"
echo "/app/fiji/fiji -macro /app/fiji_macros/Chromatic_aberration_pipeline.ijm \"$IN_DIR/,$IN_FNAME,$OUT_DIR/,$MICROSCOPE,$OBJECTIVE,$CAPTURE_DATE,$DIMX,$DIST_JSON_DIR\" > $OUT_DIR/distCorrection.log 2>&1"
/app/fiji/fiji -macro /app/fiji_macros/Chromatic_aberration_pipeline.ijm "$IN_DIR/,$IN_FNAME,$OUT_DIR/,$MICROSCOPE,$OBJECTIVE,$CAPTURE_DATE,$DIMX,$DIST_JSON_DIR" > $OUT_DIR/distCorrection.log 2>&1 &

# Monitor Fiji and take periodic screenshots, killing it eventually
fpid=$!
. /app/scripts/utils/monitorXvfb.sh $PORT $fpid 3600

# Save the log files
cp $OUT_DIR/Distortion_Correction_log*_${IN_FNAME}.txt .
