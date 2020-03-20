#!/usr/bin/env bash

helpmsg="<ANTs-tool|regiprep|deformImage> [<tool-specific-args>]"

if [ $# == 0 ] ; then
    echo "${helpmsg}"
    exit 1
fi

umask 0002

tool="$1"
shift

if [ ${tool} == "regiprep" ] ; then
    cd /regiprep
    python3 regiprep.py "$@"
elif [ ${tool} == "deformImage" ] ; then
    # extract warp parameters

    image_dimension=3
    output_dir=""
    positional_args=""

    while [[ $# > 0 ]]; do
        key="$1"
	if [ "$key" == "" ] ; then
            break
    	fi
        shift # past the key
        case $key in
            -dim|--image-dimension)
                image_dimension=$1
                shift # past value
                ;;
            -input)
	        image_input=$1
                bn_image_input=$(basename ${image_input%_pp.nii.gz})
        	if [ "${output_dir}" == "" ] ; then
		    output_dir=$(dirname ${image_input})
                    output_dir="${output_dir}/labels"
    	        fi
                image_output="${bn_image_input}-warp.nii.gz"
                shift
	        ;;
            -odir)
                output_dir=$1
		shift
                ;;
            -h|--help)
                echo "$0 [-dim <image dimension>] -input <moving image> [-odir <output dir>] [-h] <positional args such as transformations or --use-NN>"
                exit 0
                ;;
            *)
                # positional argument
                positional_args="${positional_args} $key"
                ;;
        esac
    done

    if [ -z "${image_input}" ]; then
        echo "$0 [-dim <image dimension>] -input <moving image> [-odir <output dir>] [-h] <positional args such as transformations or --use-NN>"
        exit 1
    fi

    /ANTs-build/bin/WarpImageMultiTransform ${image_dimension} ${image_input} "${output_dir}/image_output" ${positional_args}

else
    /ANTs-build/bin/${tool} "$@"
fi