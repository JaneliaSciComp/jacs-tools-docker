#!/bin/bash

umask 0002

/miniconda/bin/python /app/src/tools/convert_subtree.py $*
