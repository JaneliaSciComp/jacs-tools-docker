#!/bin/bash

echo "Run aligner with $*"

DIR=$(cd "$(dirname "$0")"; pwd)

xyres=
zres=
num_channels=2
nslots=2
input_filepath=
output_dir=

help_cmd="$0 
    --xyres <xy resolution in um>
    --zres <z resolution in um>
    --nslots <nslots (default = 2)>
    --nchannels <number of channels (default = 2)>
    --templatedir <template config directory>
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
export WORKING_DIR="${output_dir}/temp"
echo "Create working directory ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

JAVA_PREFS_DIR="${WORKING_DIR}/.java"
echo "Set java preferences directory to ${JAVA_PREFS_DIR}"
mkdir -p "${JAVA_PREFS_DIR}/sprefs"
mkdir -p "${JAVA_PREFS_DIR}/uprefs"

export JAVA_OPTS="-Djava.util.prefs.systemRoot=${JAVA_PREFS_DIR}/sprefs -Djava.util.prefs.userRoot=${JAVA_PREFS_DIR}/uprefs"

function cleanTemp {
    if [[ ${DEBUG_MODE} =~ "debug" ]]; then
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

ALIGNMENT_OUTPUT="${output_dir}/aligned"
mkdir -p ${ALIGNMENT_OUTPUT}

export FINALOUTPUT=${ALIGNMENT_OUTPUT}

echo "~ Run alignment: ${input_filepath} ${nslots} ${num_channels} ${xyres} ${zres}"
/opt/aligner/20xBrain_Align_CMTK.sh ${input_filepath} ${nslots} ${num_channels} ${xyres} ${zres}

cd ${output_dir}
echo ""
echo "~ Listing working files:"
echo ""
ls -lR $WORKING_DIR

alignment_results=$(shopt -s nullglob dotglob; echo ${ALIGNMENT_OUTPUT}/*.v3dpbd)
echo "Alignment results: ${alignment_results[@]}"
if (( ${#alignment_results} )); then
    echo "~ Finished alignment: ${input_filepath}"
    cleanTemp
    exit 0
else
    echo "~ No alignment results were found after alignment of ${YAML_CONFIG_FILE} ${WORKING_DIR} ${shape}"
    exit 1
fi
