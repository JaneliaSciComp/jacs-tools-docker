FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y build-essential git wget

WORKDIR /tmp-install
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O miniconda-install.sh

RUN bash miniconda-install.sh -b -p /miniconda

RUN apt-get install -y \
    python3-opengl

ENV PATH=/miniconda/bin:${PATH}

COPY conda-requirements.yml /tmp-install/

RUN conda config --set always_yes yes && \
    conda update -q conda && \
    conda install python=3.9 && \
    conda env update -n base -f /tmp-install/conda-requirements.yml

ENV PYTHONPATH=/app/src:${PYTHONPATH}

# clone pyktx repo
WORKDIR /app
RUN git clone https://github.com/JaneliaSciComp/pyktx.git .
RUN pip install -e .


WORKDIR /tmplibtiff
RUN git clone https://github.com/pearu/pylibtiff.git .
RUN pip install -e .

ENTRYPOINT ["/miniconda/bin/python", "/app/src/tools/convert_subtree.py"]
