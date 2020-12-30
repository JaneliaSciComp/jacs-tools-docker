#!/bin/sh
#
# Create Maximum Intensity Pojections
#
DIR=$(cd "$(dirname "$0")"; pwd)

NETPBM_PATH="/usr"
NETPBM_BIN="$NETPBM_PATH/bin"
Vaa3D="/app/vaa3d/vaa3d"
NSDIR="/app/neusep"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETPBM_PATH/lib"

##################
# inputs
##################

NUMPARAMS=$#
if [ $NUMPARAMS -lt 3 ]
then
    echo " "
    echo " USAGE ::  "
    echo " sh mipCreator.sh <output dir> <output format> <input file> \"<signal channels>\" \"<ref channel>\""
    echo " Note: channel numbers are separated by spaces, and zero indexed."
    echo " Output format may be any 'png' or 'jpg', but defaults to 'png'"
    echo " "
    exit
fi

OUTDIR=$1
FORMAT=$2
INPUT_FILE=$3
SIGNAL_CHAN=$4
REF_CHAN=$5

ALL_CHAN=""
if [ "$REF_CHAN" == "0" ]; then
    ALL_CHAN="$REF_CHAN $SIGNAL_CHAN"
else 
    ALL_CHAN="$SIGNAL_CHAN $REF_CHAN"
fi

export TMPDIR="$OUTDIR"
WORKING_DIR=`mktemp -d`
cd $WORKING_DIR

if [ ! -s $INPUT_FILE ]; then
    echo "Input file does not exist: $INPUT_FILE"
    exit 1
fi

OUTEXT=$FORMAT
if [ "$FORMAT" == "jpg" ]; then
    FORMAT="jpeg"
fi

INPUT_FILENAME=`basename $INPUT_FILE`
FILE_STUB=${INPUT_FILENAME%.*}

echo "Run Dir: $DIR"
echo "Working Dir: $WORKING_DIR"
echo "Input file: $INPUT_FILE"
echo "Output dir: $OUTDIR"
echo "Signal channels: $SIGNAL_CHAN"
echo "Reference channel: $REF_CHAN"
echo "All channels: $ALL_CHAN"
echo "Output format: $FORMAT"
echo "Output extension: $OUTEXT"

EXT=${INPUT_FILE#*.}
if [ "$EXT" == "v3dpbd" ] || [ "$EXT" == "lsm" ]; then
    PBD_INPUT_FILE=$INPUT_FILE
    INPUT_FILE_STUB=`basename $PBD_INPUT_FILE`
    INPUT_FILE="$WORKING_DIR/${INPUT_FILE_STUB%.*}.v3draw"
    echo "~ Converting $PBD_INPUT_FILE to $INPUT_FILE "
    $Vaa3D -cmd image-loader -convert "$PBD_INPUT_FILE" "$INPUT_FILE"
fi

createMip() 
{
    NAME="$1"
    CHANNELS="$2"
    CE_FLAGS="$3"
    MIP="${FILE_STUB}_${NAME}.tif"
    MIP_EN="${FILE_STUB}_${NAME}_en.tif"
    MIP_FINAL="${FILE_STUB}_${NAME}.${OUTEXT}"
    echo "~ Generating $NAME MIP from channels $CHANNELS with flags $CE_FLAGS"

    SIGNAL_MIP_PPM="${FILE_STUB}_${NAME}.ppm"
    cat $INPUT_FILE | $NSDIR/v3draw_select_channels $CHANNELS | $NSDIR/v3draw_to_8bit | $NSDIR/v3draw_to_mip | $NSDIR/v3draw_to_ppm > $SIGNAL_MIP_PPM

    if [[ ${NAME} == "signal" && ${#CHANNELS} -lt 3 ]] ; then
        # single signal channel will come out as greyscale, so let's colorize it
        echo "Converting single channel signal MIP to red"
        $NETPBM_BIN/ppmtopgm $SIGNAL_MIP_PPM | $NETPBM_BIN/pgmtoppm "#FF0000" > tmp.ppm
        mv tmp.ppm $SIGNAL_MIP_PPM
    fi
    cat $SIGNAL_MIP_PPM | $NETPBM_BIN/pamtotiff -truecolor > $MIP

    $Vaa3D -x ireg -f iContrastEnhancer -i $MIP -o $MIP_EN $CE_FLAGS
    if [ -s $MIP_EN ]; then
        MIP=$MIP_EN
    fi

    $NETPBM_BIN/tifftopnm $MIP | $NETPBM_BIN/pnmto${FORMAT} > $MIP_FINAL
}

if [ ! -z "$SIGNAL_CHAN" ]; then
    createMip "signal" "$SIGNAL_CHAN" "-p \"#m 5.0\""
fi

if [ ! -z "$REF_CHAN" ]; then
    createMip "reference" "$REF_CHAN" ""
fi

#if [ ${#ALL_CHAN} -lt 6 ]; then
#    if [ ! -z "$ALL_CHAN" ]; then
#        createMip "all" "$ALL_CHAN" "-p \"#m 5.0\""
#    fi
#fi

echo "~ Copying final output to: $OUTDIR"
mkdir -p $OUTDIR
cp *.${OUTEXT} $OUTDIR

echo "~ Removing temp directory: $WORKING_DIR"
rm -rf $WORKING_DIR

echo "~ Finished"

