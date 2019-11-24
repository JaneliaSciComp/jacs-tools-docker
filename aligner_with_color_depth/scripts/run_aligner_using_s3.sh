#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

templates_s3bucket_name=
inputs_s3bucket_name=
outputs_s3bucket_name=
input_filepath=
neuron_mask=
output_dir=
other_args=()
mounting_protocol=

help_cmd="$0 
    --templates-s3bucket-name <template S3 bucket name>
    --inputs-s3bucket-name <inputs S3 bucket name>
    --outputs-s3bucket-name <outputs S3 bucket name>
    --nmask <neuron mask path in the inputs bucket>
    -i <input filepath in the inputs bucket>
    -o <output path in the outputs bucket>
    <other aligner args (see run_aligner.sh)>
    -h"

while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
        --mprotocol)
            mounting_protocol="$1"
            shift # past value
            ;;
        --templates-s3bucket-name)
            templates_s3bucket_name="$1"
            shift # past value
            ;;
        --inputs-s3bucket-name)
            inputs_s3bucket_name="$1"
            shift # past value
            ;;
        --outputs-s3bucket-name)
            outputs_s3bucket_name="$1"
            shift # past value
            ;;
        -i|--input)
            input_filepath="$1"
            shift # past value
            ;;
        --nmask)
            neuron_mask="$1"
            shift # past value
            ;;
        -o|--output)
            output_dir="$1"
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
            other_args=("${other_args[@]}" ${key})
            ;;
    esac
done

export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

template_dirname=${S3_TEMPLATES_MOUNTPOINT}

# the script assumes there is a /scratch directory available
WORKING_DIR="/scratch/alignworkspace"

function cleanWorkingDir {
    if [[ ${DEBUG_MODE} =~ "debug" ]] ; then
        echo "~ Debugging mode - Leaving working directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}
trap cleanWorkingDir EXIT

# create inputs and outputs directories
inputs_dir="${WORKING_DIR}/inputs"
results_dir="${WORKING_DIR}/results"

mkdir -p ${inputs_dir}
mkdir -p ${results_dir}

input_filename=`basename ${input_filepath}`
echo "Copy s3://${inputs_s3bucket_name}${input_filepath} -> ${inputs_dir}"
aws s3 cp "s3://${inputs_s3bucket_name}${input_filepath}" ${inputs_dir}
working_input_filepath="${inputs_dir}/${input_filename}"

if [[ "${neuron_mask}" != "" ]] ; then
    neuron_mask_filename=`basename ${neuron_mask}`
    echo "Copy neuron mask from s3://${inputs_s3bucket_name}${neuron_mask} to ${inputs_dir}"
    aws s3 cp "s3://${inputs_s3bucket_name}${neuron_mask}" ${inputs_dir}
    working_neuron_mask="${inputs_dir}/${neuron_mask_filename}"
    nmask_arg="--nmask ${working_neuron_mask}"
else
    nmask_arg=
fi

echo "Mount the S3 buckets using s3fs"

s3fs_opts="-o use_path_request_style,nosscache"
/usr/bin/s3fs ${templates_s3bucket_name} ${S3_TEMPLATES_MOUNTPOINT} ${s3fs_opts}

run_align_cmd_args=(
    --templatedir ${template_dirname}
    -i ${working_input_filepath}
    ${nmask_arg}
    -o ${results_dir}
    --mprotocol "\"${mounting_protocol}\""
    "${other_args[@]}"
)
echo "Run: /opt/aligner-scripts/run_aligner.sh ${run_align_cmd_args[@]}"
/opt/aligner-scripts/run_aligner.sh "${run_align_cmd_args[@]}"

# copy the results to the s3 output bucket
echo "Copy ${results_dir}/color_depth_mips -> s3://${outputs_s3bucket_name}${output_dir}"
aws s3 cp --recursive "${results_dir}/color_depth_mips" "s3://${outputs_s3bucket_name}${output_dir}"
