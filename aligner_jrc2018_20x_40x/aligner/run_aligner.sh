#!/bin/bash

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

help_cmd="$0 --area <area>"
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
        --template)
            template_dirname=$1
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

cat >${output_dir}/align.yml <<EOL
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
