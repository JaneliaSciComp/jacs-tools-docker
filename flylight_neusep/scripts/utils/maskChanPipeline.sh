#!/bin/sh
#
# Generate mask and chan files for all neurons in a neuron separation
#
# Usage:
# sh maskChanPipeline.sh <separate dir> <working dir>

DIR=$(cd "$(dirname "$0")"; pwd)

. /app/scripts/utils/common.sh

NETPBM_PATH="/usr"
NETPBM_BIN="$NETPBM_PATH/bin"
Vaa3D="/app/vaa3d/vaa3d"
NSDIR="/app/neusep"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETPBM_PATH/lib"

##################
# inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 1 ]
then
    echo " "
    echo " USAGE ::  "
    echo " sh maskChanPipeline.sh <separate dir> <working dir>"
    exit
fi

SEPDIR=$1 # e.g. /nrs/jacs/jacsData/filestore/.../separate

LABEL_FILE="$SEPDIR/ConsolidatedLabel.v3dpbd"
SIGNAL_FILE="$SEPDIR/ConsolidatedSignal.v3dpbd"
REF_FILE="$SEPDIR/Reference.v3dpbd"

if [ ! -f "$LABEL_FILE" ]; then
    LABEL_FILE="$SEPDIR/ConsolidatedLabel.v3draw"
    if [ ! -f "$LABEL_FILE" ]; then
        echo "Label file not found: $LABEL_FILE"
        exit
    fi
fi

if [ ! -f "$SIGNAL_FILE" ]; then
    SIGNAL_FILE="$SEPDIR/ConsolidatedSignal.v3draw"
    if [ ! -f "$SIGNAL_FILE" ]; then
        echo "Signal file not found: $SIGNAL_FILE"
        exit
    fi
fi

if [ ! -f "$REF_FILE" ]; then
    REF_FILE="$SEPDIR/Reference.v3draw"
    if [ ! -f "$REF_FILE" ]; then
        echo "Reference file not found: $REF_FILE"
        exit
    fi
fi

OUTDIR=$SEPDIR/archive/maskChan
export TMPDIR="$SEPDIR"
WORKING_DIR=`mktemp -d`
cd $WORKING_DIR

echo "Run Dir: $DIR"
echo "Working Dir: $WORKING_DIR"
echo "Label file: $LABEL_FILE"
echo "Signal file: $SIGNAL_FILE"
echo "Output dir: $OUTDIR"

echo "~ Creating mask/chan files with $NFE_MAX_THREAD_COUNT threads"
echo "$Vaa3D -cmd neuron-fragment-editor -mode reverse-label -sourceImage $SIGNAL_FILE -labelIndex $LABEL_FILE -outputDir $WORKING_DIR -outputPrefix neuron -maxThreadCount $NFE_MAX_THREAD_COUNT"
$Vaa3D -cmd neuron-fragment-editor -mode reverse-label -sourceImage $SIGNAL_FILE -labelIndex $LABEL_FILE -outputDir $WORKING_DIR -outputPrefix neuron -maxThreadCount $NFE_MAX_THREAD_COUNT

# KR 2018/03: disable ref channel mask/chan files because they're horribly inefficient and not used anymore
#echo "~ Creating mask/chan reference files"
#echo "$Vaa3D -cmd neuron-fragment-editor -mode mask-from-stack -sourceImage $REF_FILE -channel 1 -threshold 0.08 -outputDir $WORKING_DIR  -outputPrefix ref"
#$Vaa3D -cmd neuron-fragment-editor -mode mask-from-stack -sourceImage $REF_FILE -channel 1 -threshold 0.08 -outputDir $WORKING_DIR -outputPrefix ref

mkdir -p $OUTDIR
if ls core* &> /dev/null; then
    echo "~ Error: core dumped in maskChan pipeline"
    touch $SEPDIR/core
else
    echo "~ Moving files to final output directory"
    mv $WORKING_DIR/* $OUTDIR
fi

echo "~ Removing maskChan temp files"
rm -rf $WORKING_DIR

echo "~ Finished with maskChan pipeline"

