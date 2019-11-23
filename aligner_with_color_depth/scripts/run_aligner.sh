#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

area=
shape=
gender=
image_size=
voxel_size=
mounting_protocol=
num_channels=2
ref_channel=2
objective=20x
nslots=2
template_dirname=
input_filepath=
neuron_mask=
output_dir=

help_cmd="$0 
    --area <area>
    --shape <Brain shape - Valid values: {Intact, Both_OL_missing (40x), Unknown}>
    --gender <gender>
    --isize <image size>
    --vsize <voxel size>
    --mprotocol <mounting protocol>
    --nslots <nslots (default = 2)>
    --nmask <neuron mask>
    --nchannels <number of channels (default = 2)>
    --refchannel <reference channel (default = 2)>
    --objective <objective (default = 20x)>
    --templatedir <template config directory>
    -i <input file stack>
    -o <output directory>
    -debug
    -h"
while [[ $# > 0 ]]; do
    key="$1"
    if [ "$key" == "" ] ; then
	    break
    fi
    shift # past the key
    case $key in
        --area)
            area=$1
            shift # past value
            ;;
        --shape)
            shape=$1
            shift # past value
            ;;
        --gender)
            gender=$1
            shift # past value
            ;;
        --isize)
            image_size=$1
            shift # past value
            ;;
        --vsize)
            voxel_size=$1
            shift # past value
            ;;
        --mprotocol)
            mounting_protocol=$1
            shift # past value
            ;;
        --nchannels)
            num_channels=$1
            shift # past value
            ;;
        --refchannel)
            ref_channel=$1
            shift # past value
            ;;
        --objective)
            objective=$1
            shift # past value
            ;;
        --nslots)
            nslots=$1
            shift
            ;;
        --templatedir)
            template_dirname=$1
            shift # past value
            ;;
        -i|--input)
            input_filepath=$1
            shift # past value
            ;;
        --nmask)
            neuron_mask=$1
            shift # past value
            ;;
        -o|--output)
            output_dir=$1
            shift # past value
            ;;
        -debug)
            export DEBUG_MODE=debug
            # no need to shif
            ;;
        -h|--help)
            echo "${help_cmd}"
            exit 0
            ;;
        *)
            echo "${help_cmd}"
            exit 1
            ;;
    esac
done

default_fb_mode="xvfb"
export NSLOTS=${NSLOTS:-$nslots}
export FB_MODE=${FB_MODE:-$default_fb_mode}

WORKING_DIR=${output_dir}/temp
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

function cleanTemp {
    if [[ ${DEBUG_MODE} =~ "debug" ]]; then
        echo "~ Debugging mode - Leaving temp directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}

if [[ $FB_MODE =~ "xvfb" ]]; then
    echo "initialize virtual framebuffer"
    START_PORT=`shuf -i 5000-6000 -n 1`
    XVFB_WORKING_DIR=${output_dir}/xvfb_temp
    mkdir -p ${XVFB_WORKING_DIR}
    . $DIR/init_xvfb.sh ${START_PORT} ${XVFB_WORKING_DIR}
    function exitHandler() { cleanXvfb; cleanTemp; }
    trap exitHandler EXIT
else
    function exitHandler() { cleanTemp; }
    trap exitHandler EXIT
fi

YAML_CONFIG_FILE=${output_dir}/align.yml ${output_dir} ${area}

cat > ${YAML_CONFIG_FILE} <<EOL
template_dir: ${template_dirname}
inputs:
- area: ${area}
  filepath: ${input_filepath}
  gender: ${gender}
  image_size: ${image_size}
  mounting_protocol: ${mounting_protocol}
  neuron_mask: ${neuron_mask}
  num_channels: ${num_channels}
  objective: ${objective}
  ref_channel: ${ref_channel}
  voxel_size: ${voxel_size}
EOL

echo "~ Run alignment: ${YAML_CONFIG_FILE} ${WORKING_DIR} ${shape}"
/opt/aligner/20xBrain_Align_CMTK.sh ${YAML_CONFIG_FILE} ${WORKING_DIR} ${shape}

cd ${output_dir}
echo ""
echo "~ Listing working files:"
echo ""
ls -lR $WORKING_DIR

echo "~ Moving final output to ${output_dir}"
mv ${WORKING_DIR}/FinalOutputs/* ${output_dir}

echo "~ Finished alignment: ${YAML_CONFIG_FILE} ${WORKING_DIR} ${shape}"

cleanTemp

# setup color depth output directory - make sure that it ends with a slash because 
# the fiji macro simply appends the output filename to this
COLOR_DEPTH_MIPS_OUTPUT_DIR="${output_dir}/color_depth_mips/"
echo "~ Generate color depth mips ${area} ${output_dir} ${COLOR_DEPTH_MIPS_OUTPUT_DIR}"
/opt/color_depth/color_depth.sh ${area} ${output_dir} ${COLOR_DEPTH_MIPS_OUTPUT_DIR}

echo "~ Finished"
