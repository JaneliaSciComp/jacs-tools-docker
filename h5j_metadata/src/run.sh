#!/bin/bash

# Note that it would be much cleaner to use something like this:
#   conda run -n py3 python /app/h5j_metadata.py
# Unfortunately, conda tries to write a temporary file at /opt/conda/envs/py3, 
# even with TMPDIR overriden in the environment. So although this works if you 
# run with Docker, it failes with a permission error with Singularity, 
# since the filesystem is read-only.

source /opt/conda/etc/profile.d/conda.sh
conda activate py3
python /app/h5j_metadata.py "$@"
