#!/bin/bash

originalImageFilePath=$1
consolidatedSignalLabelIndexFilePath=$2
commaSeparatedFragmentList=$3
finalOutputMIPPath=$4
newOutputStackPath=$5

. /app/scripts/utils/initXvfb.sh

WORKING_DIR=`mktemp -d`
tempOutputMIPPath=$WORKING_DIR/temp.tif

/app/vaa3d/vaa3d -cmd neuron-fragment-editor -sourceImage "$originalImageFilePath" -labelIndex "$consolidatedSignalLabelIndexFilePath" -fragments $commaSeparatedFragmentList -outputMip "$tempOutputMIPPath" -outputStack "$newOutputStackPath"

/usr/bin/convert -flip "$tempOutputMIPPath" "$finalOutputMIPPath" && rm -f "$tempOutputMIPPath"

