#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

templates_s3bucket_name=
inputs_s3bucket_name=
outputs_s3bucket_name=
input_filepath=
neuron_mask=
output_dir=
other_args=

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
    if [ "$key" == "" ] ; then
	    break
    fi
    shift # past the key
    case $key in
        --templates-s3bucket-name)
            templates_s3bucket_name=$1
            shift # past value
            ;;
        --inputs-s3bucket-name)
            inputs_s3bucket_name=$1
            shift # past value
            ;;
        --outputs-s3bucket-name)
            outputs_s3bucket_name=$1
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
        -h|--help)
            echo "${help_cmd}"
            exit 0
            ;;
        *)
            other_args="${other_args} ${key}"
            ;;
    esac
done

export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

template_dirname=${S3_TEMPLATES_MOUNTPOINT}
input_filepath=${S3_INPUTS_MOUNTPOINT}${input_filepath}
output_dir=${S3_OUTPUTS_MOUNTPOINT}${output_dir}

if [[ "${neuron_mask}" != "" ]]; then
    neuron_mask=${S3_INPUTS_MOUNTPOINT}${neuron_mask}
    nmask_arg="--nmask ${neuron_mask}"
else
    nmask_arg=
fi

echo "Mount the S3 buckets using s3fs"

s3fs_opts="-o use_path_request_style,nosscache"
/usr/bin/s3fs ${templates_s3bucket_name} ${S3_TEMPLATES_MOUNTPOINT} ${s3fs_opts}
/usr/bin/s3fs ${inputs_s3bucket_name} ${S3_INPUTS_MOUNTPOINT} ${s3fs_opts}
/usr/bin/s3fs ${outputs_s3bucket_name} ${S3_OUTPUTS_MOUNTPOINT} ${s3fs_opts}

/opt/aligner-scripts/run_aligner.sh \
    --templatedir ${template_dirname} \
    -i ${input_filepath} \
    ${nmask_arg} \
    -o ${output_dir} \
    --templatedir ${template_dir} \
    ${other_args}
