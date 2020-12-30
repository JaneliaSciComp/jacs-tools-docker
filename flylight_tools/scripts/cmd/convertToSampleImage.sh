#!/bin/bash

INPUT_FILENAME=$1
OUTPUT_FILENAME=$2
CHANNEL_MAPPING=$3
FLIP=$4

. /app/scripts/utils/initXvfb.sh

echo "Using $TMPDIR as temporary root"
mkdir -p $TMPDIR
WORKING_DIR=`mktemp -d`
function cleanTemp {
    rm -rf $WORKING_DIR
    echo "Cleaned up $WORKING_DIR"
}

# Two EXIT handlers
function exitHandler() { cleanXvfb; cleanTemp; }
trap exitHandler EXIT

# Go to the working directory
cd $WORKING_DIR

if [ "$FLIP" != "" ]; then

    if [ "$CHANNEL_MAPPING" != "" ]; then
        TEMP_FILE="$WORKING_DIR/flipped.v3draw"
        /app/scripts/utils/flipZ.sh "$INPUT_FILENAME" "$TEMP_FILE" 
        INPUT_FILENAME="$TEMP_FILE"
    else
        /app/scripts/utils/flipZ.sh "$INPUT_FILENAME" "$OUTPUT_FILENAME"
    fi
fi

if [ "$CHANNEL_MAPPING" != "" ]; then
    /app/scripts/channelMap.sh -i "$INPUT_FILENAME" -o "$OUTPUT_FILENAME" -m "$CHANNEL_MAPPING"
fi

echo 'Done'

