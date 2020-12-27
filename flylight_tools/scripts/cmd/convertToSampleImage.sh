#!/bin/bash

INPUT_FILENAME=$1
OUTPUT_FILENAME=$2
CHANNEL_MAPPING=$3
FLIP=$4
SCRATCH_DIR=$5

. /app/scripts/utils/legacy_init_xvfb.sh

if [ -z "$SCRATCH_DIR" ]; then
    export TMPDIR=$SCRATCH_DIR
    mkdir -p $TMPDIR
fi
WORKING_DIR=`mktemp -d`
echo "Working dir: $WORKING_DIR"

function cleanTemp {
    echo "Cleaning $WORKING_DIR"
    rm -rf $WORKING_DIR
    echo "Cleaned up $WORKING_DIR"
}

// Two EXIT handlers
function exitHandler() { cleanXvfb; cleanTemp; }
trap exitHandler EXIT

// Go to the working directory
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

