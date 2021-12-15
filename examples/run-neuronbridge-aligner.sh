localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

xhost + $localip

FB_MODE_PARAM="-e FB_MODE=false -e DISPLAY=$localip:0"

DATA_FILE=43LEXAGCaMP6s_for_nBLAST_0003.zip

LARGE_INPUT="/data/largeData/${DATA_FILE}"
LARGE_OUTPUT="/data/largeData/${DATA_FILE%.*}"

INPUT=$LARGE_INPUT
OUTPUT=$LARGE_OUTPUT
XYRES=0.55
ZREZ=1
FORCE=false

docker run \
       -v $PWD/local/testData:/data \
       -v $PWD/local/scratch:/scratch \
       -it \
       ${FB_MODE_PARAM} \
       -e TMP=/scratch \
       -e PREALIGN_TIMEOUT=3600 \
       -e PREALIGN_CHECKINTERVAL=10 \
       -e ALIGNMENT_MEMORY=10G \
       registry.int.janelia.org/jacs-scripts/neuronbridge-aligner:1.1 \
       /opt/aligner-scripts/run_aligner.sh \
       -debug \
       --forceVxSize ${FORCE} \
       --xyres ${XYRES} \
       --zres ${ZRES} \
       --nslots 4 \
       --reference-channel Signal_amount \
       --comparison_alg Max \
       --templatedir /data/templates \
       -i $INPUT \
       -o $OUTPUT \
       $*
