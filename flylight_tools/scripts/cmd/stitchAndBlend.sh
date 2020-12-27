#!/bin/bash

referenceChannelIndex=$1
inputDirectoryPath=$2
outputFilePath=$3

. /app/scripts/utils/legacy_init_xvfb.sh

# Stitch
/app/vaa3d/vaa3d -x imageStitch.so -f v3dstitch -p "#c $referenceChannelIndex #si 0" -i "$inputDirectoryPath"

# Blend
/app/vaa3d/vaa3d -x ifusion.so -f iblender -i "$inputDirectoryPath" -o "output.v3draw" -p "#s 1"

# Compress
EXT=${outputFilePath#*.}
if [ "$EXT" == "v3draw" ]; then
    mv output.v3draw $outputFilePath
else
    /app/vaa3d/vaa3d -cmd image-loader -convert output.v3draw $outputFilePath
    rm -f output.v3draw
fi

