#!/bin/bash

export PATH="/opt/conda/bin:$PATH"
source activate py3
/app/scripts/python/extract_channels.py "$@"

