FROM continuumio/miniconda3:4.8.2

RUN conda create -n py3 python=3 h5py=2.8.0 PyYAML=3.13 -y \
    && conda clean --tarballs \
    && mkdir -p /opt/conda/envs/py3/etc/conda/activate.d \
    # It's necessary to set TMPDIR for running with Singularity, because /opt/conda will be read-only
    && echo "export TMPDIR=/tmp" > /opt/conda/envs/py3/etc/conda/activate.d/env_vars.sh

WORKDIR /app
COPY src .

ENTRYPOINT [ "/app/run.sh" ]

