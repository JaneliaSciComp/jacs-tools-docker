#!/bin/bash
#
# 20x 40x brain aligner by Hideo Otsuna
#

InputFilePath=$1
NSLOTS=$2
NCHANNELS=$3
# Resolutions in microns
RESX=$4
RESZ=$5

# true or false, forcefully use the user input or the size from confocal file
ForceUseVxSize=$6

InputFileName=$(basename ${InputFilePath})
InputName=${InputFileName%.*}
InputFileParentPath=$(dirname ${InputFilePath})

WORKING_DIR=${WORKING_DIR:-"${InputFileParentPath}/${InputName}_TMP"}
DEBUG_DIR="${WORKING_DIR}/Debug"
OUTPUT="${WORKING_DIR}/Output"
FINALOUTPUT=${FINALOUTPUT:-"${WORKING_DIR}/FinalOutputs"}

TEMPLATE_DIR=${TEMPLATE_DIR:-"/data/templates"}
TemplatesDir=`realpath ${TEMPLATE_DIR}`

echo "InputFilePath: ${InputFilePath}"
echo "InputFileName: ${InputFileName}"
echo "InputName: ${InputName}"
echo "ForceUseVxSize: ${ForceUseVxSize}"
echo "Channels: ${NCHANNELS}"
echo "NSlots: ${NSLOTS}"
echo "RESX: ${RESX}"
echo "RESZ: ${RESZ}"
echo "TEMPLATE_DIR: ${TEMPLATE_DIR}"
echo "WORKING_DIR: ${WORKING_DIR}"
echo "OUTPUT: ${OUTPUT}"

# Tools
CMTK=/opt/CMTK/bin
FIJI=/opt/Fiji/ImageJ-linux64
Vaa3D=/opt/Vaa3D/vaa3d
MACRO_DIR=/opt/aligner/fiji_macros

# Fiji macros
MIPGENERATION="${MACRO_DIR}/Color_Depth_MIP_batch_0404_2019_For_Pipeline.ijm"
NRRDCONV=$MACRO_DIR"/nrrd2v3draw.ijm"
PREPROCIMG=$MACRO_DIR"/20x_40x_Brain_Global_Aligner_Pipeline.ijm"
TWELVEBITCONV=$MACRO_DIR"/12bit_Conversion.ijm"
SCOREGENERATION=$MACRO_DIR"/Score_Generator_Cluster.ijm"
REGCROP="$MACRO_DIR/TempCrop_after_affine.ijm"

BrainShape="Both_OL_missing (40x)"
objective="20x"
templateBr="JRC2018"

# Reformat a single NRRD file to the target deformation field
function reformat() {
    local _gsig="$1"
    local _TEMP="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _channel="$5"
    local _result_var="$6"
    local _opts="$7"

    if [[ -e $_sig ]]; then
        echo "Already exists: $_sig"
    else
        echo "--------------"
        echo "Running CMTK reformatting on channel $_channel"
        echo "$CMTK/reformatx --threads $NSLOTS -o $_sig $_opts --floating $_gsig $_TEMP $_DEFFIELD"
        START=`date '+%F %T'`
        $CMTK/reformatx -o "$_sig" $_opts --floating $_gsig $_TEMP $_DEFFIELD
        STOP=`date '+%F %T'`

        if [[ ! -e $_sig ]]; then
            echo -e "Error: CMTK reformatting signal failed"
            exit -1
        fi

        echo "--------------"
        echo "cmtk_reformatting $TSTRING $_channel start: $START"
        echo "cmtk_reformatting $TSTRING $_channel stop: $STOP"
        echo " "
    fi
}

# Reformat all the channels to the same template
function reformatAll() {
    local _gsig="$1"
    local _TEMP="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _result_var="$5"
    local _opts="$6"

    # Reformat each channel
    for ((i=1; i<=$NCHANNELS; i++)); do
        GLOBAL_NRRD="${_gsig}_0${i}.nrrd"
        OUTPUT_NRRD="${_sig}_0${i}.nrrd"
        reformat "$GLOBAL_NRRD" "$_TEMP" "$_DEFFIELD" "$OUTPUT_NRRD" "$i" "ignore" "$opts"
    done
}

# Alignment score generation
function scoreGen() {
    local _outname="$1"
    local _scoretemp="$2"
    local _result_var="$3"

    tempfilename=`basename $_scoretemp`
    tempname=${tempfilename%%.*}
    scorepath="$OUTPUT/${tempname}_Score.property"

     if [[ -e ${scorepath} ]]; then
        echo "Already exists: $scorepath"
    else
        echo "+---------------------------------------------------------------------------------------+"
        echo "| Running Score generation"
        echo "| $FIJI --headless -macro $SCOREGENERATION $OUTPUT/,$_outname,$NSLOTS,$_scoretemp"
        echo "+---------------------------------------------------------------------------------------+"

        START=`date '+%F %T'`
        # Expect to take far less than 1 hour
	    # Alignment Score generation:ZNCC can run in headless mode and does not need Xvfb
	
        $FIJI --headless -macro ${SCOREGENERATION} $OUTPUT/,$_outname,$NSLOTS,$_scoretemp
        STOP=`date '+%F %T'`

        echo "ZNCC JRC2018 score generation start: $START"
        echo "ZNCC JRC2018 score generation stop: $STOP"
    fi
}

function banner() {
    echo "------------------------------------------------------------------------------------------------------------"
    echo " $1"
    echo "------------------------------------------------------------------------------------------------------------"
}


# Main Script

mkdir -p $WORKING_DIR
mkdir -p $OUTPUT
mkdir -p $DEBUG_DIR
mkdir -p $FINALOUTPUT


if [[ ! -e $PREPROCIMG ]]; then
    echo "Preprocess macro could not be found at $PREPROCIMG"
    exit 1
fi

if [[ ! -e $FIJI ]]; then
    echo "Fiji cannot be found at $FIJI"
    exit 1
fi

# neuron mask is ignored
Unaligned_Neuron_Separator_Result_V3DPBD=

# "-------------------Template----------------------"
JRC2018_Unisex_Onemicron1="${TemplatesDir}/JRC2018_UNISEX_20x_onemicron.nrrd"
JRC2018_Unisex_OnemicronNoOL="${TemplatesDir}/JRC2018_UNISEX_20x_gen1_noOPonemicron.nrrd"
JRC2018_Unisexgen1CROPPED="${OUTPUT}/TempCROPPED.nrrd"

# "-------------------Global aligned files----------------------"
gloval_nc82_nrrd="${OUTPUT}/${InputName}_01.nrrd"
gloval_signalNrrd1="${OUTPUT}/${InputName}_02.nrrd"
gloval_signalNrrd2="${OUTPUT}/${InputName}_03.nrrd"
gloval_signalNrrd3="${OUTPUT}/$InputName}_04.nrrd"

# "-------------------Deformation fields----------------------"
registered_initial_xform="${OUTPUT}/initial.xform"
registered_affine_xform="${OUTPUT}/affine.xform"
registered_warp_xform="${OUTPUT}/warp.xform"

# -------------------------------------------------------------------------------------------
OLSHAPE="${OUTPUT}/OL_shape.txt"

if [[ -e $OLSHAPE ]]; then
    echo "Already exists: $OLSHAPE" &
else
    echo "+---------------------------------------------------------------------------------------+"
    echo "| Running OtsunaBrain preprocessing step"
    echo "| $FIJI -macro $PREPROCIMG \"$OUTPUT/,$InputName.,$InputFilePath,$TemplatesDir,$RESX,$RESZ,$NSLOTS,$objective,$templateBr,$BrainShape,$Unaligned_Neuron_Separator_Result_V3DPBD,$ForceUseVxSize.\""
    echo "+---------------------------------------------------------------------------------------+"
    START=`date '+%F %T'`
    # Note that this macro does not seem to work in --headless mode
    $FIJI -macro $PREPROCIMG "$OUTPUT/,$InputName.,$InputFilePath,$TemplatesDir,$RESX,$RESZ,$NSLOTS,$objective,$templateBr,$BrainShape,$Unaligned_Neuron_Separator_Result_V3DPBD,$ForceUseVxSize" > $DEBUG_DIR/preproc.log 2>&1

    STOP=`date '+%F %T'`
    echo "Otsuna_Brain preprocessing start: $START"
    echo "Otsuna_Brain preprocessing stop: $STOP"
    if [[ ${DEBUG_MODE} =~ "debug" ]]; then
        echo "~ Preprocessing output"
        cat $DEBUG_DIR/preproc.log
    fi

    # check for prealigner errors
    LOGFILE="${OUTPUT}/20x_brain_pre_aligner_log.txt"
    cp $LOGFILE $DEBUG_DIR
    PreAlignerError=`grep "PreAlignerError: " $LOGFILE | head -n1 | sed "s/PreAlignerError: //"`
    if [[ ! -z "$PreAlignerError" ]]; then
        writeErrorProperties "PreAlignerError" "JRC2018_" "$objective" "Pre-aligner rejection: $PreAlignerError"
        exit 0
    fi
fi

OL="$(<$OLSHAPE)"
echo "OLSHAPE; "$OL

iniT=${JRC2018_Unisex_Onemicron1}
if [[ ! -e ${JRC2018_Unisexgen1CROPPED} ]]; then
    cp ${JRC2018_Unisex_Onemicron1} ${JRC2018_Unisexgen1CROPPED}
fi

echo "iniT: $iniT"
echo "gloval_nc82_nrrd: $gloval_nc82_nrrd"
echo ""

# -------------------------------------------------------------------------------------------
if [[ -e ${registered_affine_xform} ]]; then
    echo "Already exists: $registered_affine_xform"
else
    echo "+----------------------------------------------------------------------+"
    echo "| Running CMTK registration"
    echo "| $CMTK/registration --threads $NSLOTS --initial $registered_initial_xform --dofs 6,9 --auto-multi-levels 4 --accuracy 0.8 -o $registered_affine_xform $iniT $gloval_nc82_nrrd "
    echo "+----------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/registration --threads $NSLOTS -i -v --dofs 6 --dofs 9 --accuracy 0.8 -o ${registered_affine_xform} ${iniT} ${gloval_nc82_nrrd}
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_affine_xform ]]; then
        echo -e "Error: CMTK registration failed"
        exit -1
    fi
    echo "cmtk_registration start: $START"
    echo "cmtk_registration stop: $STOP"

    sig="${OUTPUT}/Affine_${InputName}_01.nrrd"
    DEFFIELD=${registered_affine_xform}
    TEMP=${JRC2018_Unisexgen1CROPPED}
    gsig=${gloval_nc82_nrrd}
    iniT=${JRC2018_Unisexgen1CROPPED}

    $CMTK/reformatx -o "$sig" --floating $gsig $TEMP $DEFFIELD
    $FIJI -macro $REGCROP "$TEMP,$sig,$NSLOTS"
fi

# CMTK warping
if [[ -e $registered_warp_xform ]]; then
    echo "Already exists: $registered_warp_xform"
else
    iniT=${JRC2018_Unisexgen1CROPPED}
    
    echo "+----------------------------------------------------------------------+"
    echo "| Running CMTK warping"
    echo "| $CMTK/warp --threads $NSLOTS -o $registered_warp_xform --grid-spacing 80 --exploration 30 --coarsest 4 --accuracy 0.8 --refine 4 --energy-weight 1e-1 --initial $registered_affine_xform $iniT $gloval_nc82_nrrd"
    echo "+----------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/warp --threads $NSLOTS -o $registered_warp_xform --grid-spacing 80 --fast --exploration 26 --coarsest 8 --accuracy 0.8 --refine 4 --energy-weight 1e-1 --ic-weight 0 --initial $registered_affine_xform $iniT $gloval_nc82_nrrd
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_warp_xform ]]; then
        echo -e "Error: CMTK warping failed"
        exit -1
    fi
    echo "cmtk_warping start: $START"
    echo "cmtk_warping stop: $STOP"
fi

rm $JRC2018_Unisexgen1CROPPED

echo " "
echo "+----------------------------------------------------------------------+"
echo "| 12-bit conversion"
echo "| $FIJI -macro $TWELVEBITCONV \"${OUTPUT}/,${InputName}_01.nrrd,${gloval_nc82_nrrd}\""
echo "+----------------------------------------------------------------------+"
$FIJI --headless -macro $TWELVEBITCONV "${OUTPUT}/,${InputName}_01.nrrd,${gloval_nc82_nrrd}"

########################################################################################################
# JFRC2018 Unisex High-resolution (for color depth search) reformat
########################################################################################################

banner "JFRC2018 Unisex High-resolution (for color depth search)"
sig="${OUTPUT}/${InputName}_U_20x_HR"
DEFFIELD=${registered_warp_xform}

TEMPLATE="${TemplatesDir}/JRC2018_UNISEX_20x_HR.nrrd"

gsig="${OUTPUT}/${InputName}"

reformatAll $gsig $TEMPLATE $DEFFIELD $sig RAWOUT
scoreGen "${sig}_01.nrrd" ${TEMPLATE} "score2018"

$FIJI --headless -macro ${MIPGENERATION} "${OUTPUT}/,${sig}_02.nrrd,${WORKING_DIR}/MIP/,${TemplatesDir}/,Brain" &

rm $gsig_01.nrrd
rm $gsig_02.nrrd


cp $OUTPUT/*.{png,jpg,log,txt} $DEBUG_DIR
cp -R $OUTPUT/*.xform $DEBUG_DIR
cp $OUTPUT/REG*.v3dpbd $FINALOUTPUT
cp $OUTPUT/REG*.properties $FINALOUTPUT

echo "$0 done"
