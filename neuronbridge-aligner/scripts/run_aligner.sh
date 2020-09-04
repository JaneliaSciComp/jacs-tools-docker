#!/bin/bash

echo "Run aligner with $*"

DIR=$(cd "$(dirname "$0")"; pwd)

xyres=
zres=
num_channels=2
nslots=2
input_filepath=
output_dir=
forceVxSizeUse=false

help_cmd="$0 
    --xyres <xy resolution in um>
    --zres <z resolution in um>
    --nslots <nslots (default = 2)>
    --nchannels <number of channels (default = 2)>
    --templatedir <template config directory>
    --forceVxSize <true|false>
    -i <input file stack>
    -o <output directory>
    -debug
    -h"
while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
        --xyres)
            xyres="$1"
            shift # past value
            ;;
        --zres)
            zres="$1"
            shift # past value
            ;;
        --nchannels)
            num_channels=$1
            shift # past value
            ;;
        --forceVxSize)
            if [[ "$1" =~ "true" ]] ; then
                # if arg is true forceVxSizeUse otherwise leave it false
                forceVxSizeUse=true
            fi
            shift
            ;;
        --nslots)
            nslots=$1
            shift
            ;;
        --templatedir)
            export TEMPLATE_DIR="$1"
            shift # past value
            ;;
        -i|--input)
            input_filepath="$1"
            shift # past value
            ;;
        -o|--output)
            output_dir="$1"
            shift # past value
            ;;
        -debug)
            export DEBUG_MODE=debug
            # no need to shift
            ;;
        -h|--help)
            echo "${help_cmd}"
            exit 0
            ;;
        *)
            echo "Unknown flag ${key}"
            echo "${help_cmd}"
            exit 1
            ;;
    esac
done

if [ ! -e "${input_filepath}" ]; then
    echo "Input file path ${input_filepath} not found"
    exit 1
fi

default_fb_mode="xvfb"
export NSLOTS=${NSLOTS:-$nslots}
export FB_MODE=${FB_MODE:-$default_fb_mode}
echo "Use FB_MODE=${FB_MODE}"
export WORKING_DIR="${output_dir}/temp"
echo "Create working directory ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

function cleanTemp {
    if [[ "${DEBUG_MODE}" =~ "debug" ]]; then
        echo "~ Debugging mode - Leaving temp directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}

source ${COMMON_TOOLS_DIR}/setup_xvfb.sh
function exitHandler() { exitXvfb; cleanTemp; }
trap exitHandler EXIT

ALIGNMENT_OUTPUT=${ALIGNMENT_OUTPUT:-"${output_dir}/aligned"}
mkdir -p ${ALIGNMENT_OUTPUT}

export FINALOUTPUT=${ALIGNMENT_OUTPUT}

echo "~ Run alignment: ${input_filepath} ${nslots} ${num_channels} ${xyres} ${zres} ${forceVxSizeUse}"
/opt/aligner/20xBrain_Align_CMTK.sh ${input_filepath} ${nslots} ${num_channels} ${xyres} ${zres} ${forceVxSizeUse}
alignmentExitCode=$?
if [ $alignmentExitCode -ne 0 ]; then
    echo "Alignment terminated abnormally: $alignmentExitCode"
    exit 1
fi

cd ${output_dir}
echo ""
echo "~ Listing working files:"
echo ""
tree -s $WORKING_DIR

alignment_results=$(shopt -s nullglob dotglob; echo ${ALIGNMENT_OUTPUT}/*.nrrd)
echo "Alignment results: ${alignment_results[@]}"
if (( ${#alignment_results} )); then
    echo "~ Finished alignment: ${input_filepath}"
    cleanTemp
    exit 0
else
    echo "~ No alignment results were found after alignment of ${input_filepath} ${WORKING_DIR} ${shape}"
    exit 1
fi
