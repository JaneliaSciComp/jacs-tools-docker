#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

area=
gender=
image_size=
voxel_size="0.44x0.44x0.44"
mounting_protocol=
neuron_mask=
num_channels=4
ref_channel=4
objective=
template_dirname=
input_filepath=
output_dir=
start_display_port=10000
shape=

help_cmd="$0 
    --area <area>
    --gender <gender>
    --isize <image size>
    --vsize <voxel size (defaults to 0.44x0.44x0.44)>
    --mprotocol <mounting protocol>
    --nmask <neuron mask>
    --nchannels <number of channels (default = 4)>
    --refchannel <reference channel (default = 4)>
    --objective <objective>
    --templatedir <template config directory>
    --shape <Brain shape - Valid values: {Intact, Both_OL_missing (40x), Unknown}>
    -i <input file stack>
    -o <output directory>
    --display-port <start display port>
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
        --nmask)
            neuron_mask=$1
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
        --templatedir)
            template_dirname=$1
            shift # past value
            ;;
        --shape)
            shape=$1
            shift # past value
            ;;
        -i|--input)
            input_filepath=$1
            shift # past value
            ;;
        -o|--output)
            output_dir=$1
            shift # past value
            ;;
        --display-port)
            start_display_port=$1
            shift # past value
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

WORKING_DIR=${output_dir}/temp

function cleanTemp {
    if [[ ${DEBUG_MODE} =~ "debug" ]]; then
        echo "~ Debugging mode - Leaving temp directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}

mkdir -p ${output_dir}

if [[ $FB_MODE =~ "xvfb" ]]; then
    echo "initialize virtual framebuffer"
    . $DIR/init_xvfb.sh ${start_display_port} ${output_dir}
    function exitHandler() { cleanXvfb; cleanTemp; }
    trap exitHandler EXIT
else
    function exitHandler() { cleanTemp; }
    trap exitHandler EXIT
fi

YAML_CONFIG_FILE=${output_dir}/align.yml

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


/opt/aligner/20xBrain_Align_CMTK.sh ${YAML_CONFIG_FILE} ${output_dir} ${shape}
