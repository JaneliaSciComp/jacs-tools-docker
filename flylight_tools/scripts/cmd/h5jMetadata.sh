#!/bin/bash

INPUT_FILE=$1
YAML_FILE=$2

export PATH="/opt/conda/bin:$PATH"
source activate py3

if [ -n $YAML_FILE ]; then
    echo "/app/scripts/python/h5j_metadata.py -m $YAML_FILE $INPUT_FILE"
    /app/scripts/python/h5j_metadata.py -m $YAML_FILE $INPUT_FILE
else
    echo "/app/scripts/python/h5j_metadata.py $INPUT_FILE"
    /app/scripts/python/h5j_metadata.py $INPUT_FILE
fi
