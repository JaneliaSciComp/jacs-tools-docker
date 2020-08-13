# JACS Tools

This repository contains tools which JACS runs on the cluster to process data.
Each sub directory contains a single tool built into a Docker container which at runtime is actually imported and converted into a
Singularity container.

To build any container run:
```
./manage.sh build <container-directory>
```

## NeuronBridge Aligner

Building NeuronBridge aligner:
```
./manage.sh build neuronbridge-aligner
```

This container is used for aligning and generating MIPs of 3-D stacks for NeuronBridge.

### Running NeuronBridge aligner with local data

```
# For debugging you can pass in FB_MODE_PARAM in order to display 
# the Fiji Window - typically in production you use xvfb for that 
localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $localip
FB_MODE_PARAM="-e FB_MODE=false -e DISPLAY=$localip:0"

LOCAL_DATA_DIR=$PWD/local/testData
LOCAL_TEMPLATES_DIR=$LOCAL_DATA_DIR/templates

# these must be specified as they are seen inside the container
TEMPLATES=/alignment_templates
INPUT=/data/s4/input/ch2ch.zip
OUTPUT=/data/s4

docker run \
       -v $LOCAL_DATA_DIR:/data \
       -v $LOCAL_TEMPLATES_DIR:/alignment_templates \
       -it \
       registry.int.janelia.org/jacs-scripts/neuronbridge-aligner:1.0 \
       /opt/aligner-scripts/run_aligner.sh \
       -debug \
       --xyres 1 \
       --zres 1 \
       --nslots 4 \
       --nchannels 2 \
       --templatedir ${TEMPLATES} \
       -i $INPUT \
       -o $OUTPUT \
       $*
```

### Running NeuronBridge aligner with data on S3
```
localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $localip
FB_MODE_PARAM="-e FB_MODE=false -e DISPLAY=$localip:0"

TEMPLATES_BUCKET=janelia-flylight-color-depth-dev
INPUT_BUCKET=janelia-neuronbridge-searches-dev
OUTPUT_BUCKET=janelia-neuronbridge-searches-dev

# alignment location on S3 - this location must start wuth '/'
TEMPLATES=/alignment_templates
# input location on S3 - this should be the full "path" but not start with '/'
INPUT=data-folder-on-s3/ch2ch.zip
# results location on S3 - this should be the full "path" but not start with '/'
OUTPUT=data-folder-on-s3
# scratch directory is a local directory mapped in the container as /scratch
# for holding temporary data generated during alignment
SCRATCH_DIR=$PWD/local/scratch

docker run \
       --device /dev/fuse \
       --cap-add SYS_ADMIN \
       -v $SCRATCH_DIR:/scratch:rw \
       -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
       -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
       -e AWS_DEFAULT_REGION=us-east-1 \
       -it \
       registry.int.janelia.org/jacs-scripts/neuronbridge-aligner:1.0 \
       /opt/aligner-scripts/run_aligner_using_s3.sh \
       -debug true \
       -skipCopyInputIfExists \
       --xyres 1 \
       --zres 1 \
       --nslots 4 \
       --nchannels 2 \
       --templates-s3bucket-name $TEMPLATES_BUCKET \
       --inputs-s3bucket-name $INPUT_BUCKET \
       --outputs-s3bucket-name $OUTPUT_BUCKET \
       --templatedir $TEMPLATES \
       -i $INPUT \
       -o $OUTPUT \
       $*
```
