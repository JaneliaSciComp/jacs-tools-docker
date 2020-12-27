#!/bin/bash

referenceChannelIndex=$1
inputDirectoryPath=$2
outputFilePath=$3

. /app/scripts/utils/legacy_init_xvfb.sh

/app/vaa3d/vaa3d -x imageStitch.so -f istitch-grouping -p "#c $referenceChannelIndex" -i "$inputDirectoryPath" -o "$outputFilePath"

