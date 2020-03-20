FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y \
    build-essential doxygen swig \
    python-dev libfftw3-dev libboost-dev \
    python-numpy \
   	libz-dev \
 	python3 python3-pip \
    cmake

# clone pyca repo
WORKDIR /pyca-src
RUN git clone https://bitbucket.org/cgoina/pyca.git .
# build pyca
WORKDIR /pyca-build
RUN cmake /pyca-src
RUN make -j 8
RUN make install

# clone ANTs repo
WORKDIR /ANTs-src
RUN git clone https://github.com/GFleishman/ANTs.git .
# build ANTs
WORKDIR /ANTs-build
RUN cmake -DPyCA_DIR:PATH=/pyca-build -DPyCA_SOURCE:PATH=/pyca-src \
          -DBUILD_ALL_ANTS_APPS:BOOL=ON \
          -DRUN_LONG_TESTS:BOOL=OFF \
          -DRUN_SHORT_TESTS:BOOL=OFF \
          /ANTs-src
RUN make -j 8

# install regiprep python scripts
WORKDIR /regiprep
RUN git clone https://github.com/GFleishman/regiprep.git .
RUN pip3 install numpy scipy nibabel h5py


WORKDIR /app

# Copy the entrypoint script
COPY entrypoint.sh /app

RUN chmod 755 /app/entrypoint.sh

CMD [ "/app/entrypoint.sh" ]
