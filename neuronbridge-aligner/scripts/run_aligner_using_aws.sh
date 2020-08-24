#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

S3_TEMPLATES_MOUNTPOINT=${S3_TEMPLATES_MOUNTPOINT:-"/s3_alignment_templates"}

templates_s3bucket_name=
inputs_s3bucket_name=
outputs_s3bucket_name=
searchId=
input_filepath=
output_dir=
templates_dir_param=
other_args=()
use_iam_role=
skipCopyInputIfExists=false

help_cmd="$0 
    --templates-s3bucket-name <template S3 bucket name>
    --use-iam-role <iam role to be used by S3FS or auto, if not specified AWS keys must be set>
    --inputs-s3bucket-name <inputs S3 bucket name>
    --outputs-s3bucket-name <outputs S3 bucket name>
    --search-id <id of the search to be updated using AWS AppSync API>
    -i <input filepath in the inputs bucket>
    -o <output path in the outputs bucket>
    <other aligner args (see run_aligner.sh)>
    -debug <{true|false}>
    -h"

while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
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
        --templatedir)
            templates_dir_param="$1"
            shift # past value
            ;;
        --search-id)
            searchId="$1"
            shift
            ;;
        -i|--input)
            input_filepath="$1"
            shift # past value
            ;;
        -o|--output)
            output_dir="$1"
            shift # past value
            ;;
        --use-iam-role)
            use_iam_role="$1"
            shift
            ;;
        -skipCopyInputIfExists)
            skipCopyInputIfExists=true
            ;;
        -debug)
            debug_flag="$1"
            if [[ "${debug_flag}" =~ "true" ]] ; then
                export DEBUG_MODE=debug
            fi
            shift
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

# the script assumes there is a /scratch directory available
# the working directory is based on the output directory last component name
output_basename=`basename ${output_dir}`
WORKING_DIR="/scratch/${output_basename}"
echo "Create local working directory ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}

function cleanWorkingDir() {
    if [[ "${DEBUG_MODE}" =~ "debug" ]] ; then
        echo "~ Debugging mode - Leaving working directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}
trap cleanWorkingDir EXIT

function updateSearch() {
    local searchId=$1
    local searchStep=$2
    local mipsParam=$3

    # Update the search if a searchId is passed
    if [[ "${searchId}" != "" ]] ; then
        if ((${#mipsParam[@]} == 0)) ; then
            mipsList=
        else
            mipsList=$(printf ",\"%s\"" "${mipsParam[@]}")
            mipsList=${mipsList:1}
        fi
        searchData="{
            \"searchId\": \"${searchId}\",
            \"step\": ${searchStep},
            \"computedMIPs\": [ ${mipsList} ]
        }"
        echo ${searchData} > "${WORKING_DIR}/${searchId}-input.json"
        if [[ "${DEBUG_MODE}" =~ "debug" ]] ; then
            echo "SearchData: $(cat "${WORKING_DIR}/${searchId}-input.json")"
        fi
        printf -v updateSearchCmd "aws lambda invoke --function-name %s --log-type None --payload %s %s" \
            "${SEARCH_UPDATE_FUNCTION}" \
            "fileb://${WORKING_DIR}/${searchId}-input.json" \
            "${WORKING_DIR}/${searchId}.json"
        echo "Update search step: ${updateSearchCmd}"
        ${updateSearchCmd}
    fi
}

# create inputs and outputs directories
inputs_dir="${WORKING_DIR}/inputs"
results_dir="${WORKING_DIR}/results"

echo "Create local inputs directory ${inputs_dir}"
mkdir -p ${inputs_dir}
echo "Create local results directory ${results_dir}"
mkdir -p ${results_dir}

# copy input file to the input working directory
input_filename=`basename ${input_filepath}`
working_input_filepath="${inputs_dir}/${input_filename}"
copyInputsCmd="aws s3 cp s3://${inputs_s3bucket_name}/${input_filepath} ${working_input_filepath}"

if [[ "${skipCopyInputIfExists}" =~ "true" ]] ; then
    if [[ ! -e ${working_input_filepath} ]] ;  then
        echo "Copy inputs: ${copyInputsCmd}"
        `${copyInputsCmd}`
    fi
else
    echo "Copy inputs: ${copyInputsCmd}"
    `${copyInputsCmd}`
fi

if [[ "${templates_s3bucket_name}" != "" ]] ; then
    echo "Mount S3 templates buckets using s3fs"

    s3fs_opts="-o use_path_request_style,nosscache"
    if [[ "${use_iam_role}" != "" ]] ; then
        s3fs_opts="${s3fs_opts} -o iam_role=${use_iam_role}"
    elif [[ "${AWSACCESSKEYID}" != "" ]] ; then
        passwd_file=/scratch/.passwd-s3fs
        echo $AWSACCESSKEYID:$AWSSECRETACCESSKEY > ${passwd_file}
        chmod 600 ${passwd_file}
        s3fs_opts="${s3fs_opts} -o passwd_file=${passwd_file}"
    fi
    # mount templates directory
    mountTemplatesCmd="/usr/bin/s3fs ${templates_s3bucket_name} ${S3_TEMPLATES_MOUNTPOINT} ${s3fs_opts}"
    echo "Mount templates from S3: ${mountTemplatesCmd}"
    ${mountTemplatesCmd}
    if [[ "${templates_dir_param}" != "" ]] ; then
        templates_dir=${S3_TEMPLATES_MOUNTPOINT}/${templates_dir_param}
    else
        templates_dir=${S3_TEMPLATES_MOUNTPOINT}
    fi
    lsTemplatesCmd="ls ${templates_dir}"
    templatesCount=`${lsTemplatesCmd} | wc -l`
    echo "Found ${templatesCount} after running ${lsTemplatesCmd}"
    if [[ "${DEBUG_MODE}" =~ "debug" ]] ; then
        # list templates content  if debug is on
        echo "${lsTemplatesCmd}"
        ${lsTemplatesCmd}
    fi
    templates_dir_arg="--templatedir ${templates_dir}"
else
    # will use default templates
    templates_dir_arg=""
fi

export MIPS_OUTPUT="${results_dir}/mips"

mips=()
echo "Set alignment in progress for ${searchId}: ${mips[@]}"
updateSearch ${searchId} 1 ${mips[@]}

run_align_cmd_args=(
    ${templates_dir_arg}
    -i ${working_input_filepath}
    -o ${results_dir}
    "${other_args[@]}"
)

echo "Run: /opt/aligner-scripts/run_aligner.sh ${run_align_cmd_args[@]}"
/opt/aligner-scripts/run_aligner.sh "${run_align_cmd_args[@]}"
alignment_exit_code=$?
if [[ "${alignment_exit_code}" != "0" ]] ; then
    echo "Alignment exited with $alignment_exit_code";
    exit $alignment_exit_code
fi

# copy the results to the s3 output bucket
copyMipsCmd="aws s3 cp ${MIPS_OUTPUT}/*.tif s3://${outputs_s3bucket_name}/${output_dir}/"
echo "Copy MIPS: ${copyMipsCmd}"
${copyMipsCmd}

for mip in `ls ${MIPS_OUTPUT}/*.tif` ; do
    mips=("${mips[@]}" ${mip})
done

echo "Set alignment to completed for ${searchId}: ${mips[@]}"
updateSearch ${searchId} 2 ${mips[@]}

if [[ "${DEBUG_MODE}" != "debug" ]] ; then
    # delete the input
    echo "Remove s3://${inputs_s3bucket_name}/${input_filepath}"
    aws s3 rm "s3://${inputs_s3bucket_name}/${input_filepath}"
    echo "Remove working input copy: ${working_input_filepath}"
    rm -f ${working_input_filepath}
fi
