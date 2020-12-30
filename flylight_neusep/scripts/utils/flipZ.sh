#!/bin/bash
#
# Normalize a face down image by flipping it over like a pancake.
#
# Temporarily creates working files in the current working directory.
#

if [ $# -ne 2 ]; then
    echo "Usage: `basename $0` [source path] [target path]"
    exit 65
fi

# Exit on error
set -e

Vaa3D="/app/vaa3d/vaa3d"
SOURCE_FILE=$1
TARGET_FILE=$2

echo "Vaa3D: $Vaa3D"
echo "Source: $SOURCE_FILE"
echo "Target: $TARGET_FILE"

TEMP_FILE1="ymirrored.v3draw"
#TEMP_FILE2="zflipped.v3draw"

echo "Mirroring in Y-axis"
time $Vaa3D -x ireg -f xflip -i $SOURCE_FILE -o $TEMP_FILE1
echo "Mirroring in Z-axis"
time $Vaa3D -x ireg -f zflip -i $TEMP_FILE1 -o $TARGET_FILE

# This is useful for images that are rotated 45 degrees, but it messes up images that are not rotated to begin with
#echo "Rotating back"
#time $Vaa3D -x rotate -f left90 -i $TEMP_FILE2 -o $TARGET_FILE

echo "Removing temporary files"
rm $TEMP_FILE1
#rm $TEMP_FILE2

echo "Flip completed"
