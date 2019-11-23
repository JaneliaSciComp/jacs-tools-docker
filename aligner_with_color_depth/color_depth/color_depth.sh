#!/bin/bash

area=$1
input_dir=$2
output_dir=$3

masks_dir=${4:-/opt/color_depth/aligned_masks/}

mkdir -p ${output_dir}

function run_cd_mips {
    current_input_dir=`dirname $1`"/"
    input_file=`basename $1`
    run_fiji_cmd="/opt/Fiji/ImageJ-linux64 -macro /opt/color_depth/fiji_macros/Color_Depth_MIP_batch_For_Pipeline.ijm ${current_input_dir},${input_file},${output_dir},${masks_dir},${area}"
    echo "Execute $run_fiji_cmd"
    `$run_fiji_cmd`
}

for i in `find $input_dir -name "*.v3dpbd"`; do 
    echo "Run color depth mips for $i"
    run_cd_mips $i; 
done
