FROM condaforge/miniforge3:24.3.0-0

RUN conda create -n py3 python=3 h5py=2.8.0 PyYAML=3.13 -y \
    && conda clean --tarballs \
    && mkdir -p /opt/conda/envs/py3/etc/conda/activate.d \
    # It's necessary to set TMPDIR for running with Singularity, because /opt/conda will be read-only
    && echo "export TMPDIR=/tmp" > /opt/conda/envs/py3/etc/conda/activate.d/env_vars.sh

WORKDIR /app
RUN printf '#!/bin/bash\nsource /opt/conda/etc/profile.d/conda.sh\nconda activate py3\npython /app/src/h5j_metadata.py "$@"\n' \
    >> /app/run.sh \
    && chmod +x /app/run.sh
ADD . .

ENTRYPOINT [ "/app/run.sh" ]

