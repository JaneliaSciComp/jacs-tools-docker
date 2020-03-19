FROM continuumio/miniconda3

RUN apt-get update && \
    apt-get install -y \
        build-essential procps wget \
        unzip libxext-dev libxt-dev libxmu-dev

# install Matlab-2017a
WORKDIR /mcr-install

RUN wget http://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip
RUN unzip MCR_R2017a_glnxa64_installer.zip
RUN ./install -mode silent -agreeToLicense yes

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:\
/usr/local/MATLAB/MATLAB_Runtime/v92/runtime/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v92/bin/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v92/sys/os/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v92/sys/opengl/lib/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v92/sys/java/jre/glnxa64/jre/lib/amd64/server:\
/usr/local/MATLAB/MATLAB_Runtime/v92/sys/java/jre/glnxa64/jre/lib/amd64
ENV APPLRESDIR=/usr/local/MATLAB/MATLAB_Runtime/v92/X11/app-defaults
ENV MCR_CACHE_VERBOSE=true

WORKDIR /app
RUN rm -rf /mcr-install

# Copy the entrypoint script
COPY entrypoint.sh /app
COPY clusterMF_fn /app

RUN chmod 755 /app/entrypoint.sh /app/clusterMF_fn

CMD [ "/app/entrypoint.sh" ]
