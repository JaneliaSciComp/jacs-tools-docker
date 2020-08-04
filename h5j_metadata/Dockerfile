FROM continuumio/miniconda3:4.8.2

RUN conda create -n py3 python=3 h5py=2.8.0 PyYAML=3.13 -y \
    && conda clean --tarballs \
    && conda env config vars set TMPDIR=/tmp \
    && conda init bash

WORKDIR /app
COPY src .

ENTRYPOINT [ "conda", "run", "-n", "py3", "python", "/app/h5j_metadata.py" ]
