FROM continuumio/miniconda3:4.6.14

RUN conda create -n py3 python=3 h5py=2.8.0 PyYAML=3.13 -y \
    && conda clean --tarballs

WORKDIR /app
COPY src .

ENTRYPOINT [ "conda", "run", "-n", "py3", "python", "/app/h5j_metadata.py" ]