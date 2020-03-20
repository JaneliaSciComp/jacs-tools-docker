FROM continuumio/miniconda3

RUN apt-get update && \
    apt-get install -y \
        build-essential procps wget \
        unzip libxext-dev libxt-dev libxmu-dev

# install Matlab-2017a
WORKDIR /mcr-install

RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2019a/Release/5/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019a_Update_5_glnxa64.zip
RUN unzip MATLAB_Runtime_R2019a_Update_5_glnxa64.zip
RUN ./install -mode silent -agreeToLicense yes

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:\
/usr/local/MATLAB/MATLAB_Runtime/v96/runtime/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v96/bin/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v96/sys/os/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v96/sys/opengl/lib/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/v96/sys/java/jre/glnxa64/jre/lib/amd64/server:\
/usr/local/MATLAB/MATLAB_Runtime/v96/sys/java/jre/glnxa64/jre/lib/amd64
ENV XAPPLRESDIR=/usr/local/MATLAB/MATLAB_Runtime/v96/X11/app-defaults
ENV MCR_CACHE_VERBOSE=true

WORKDIR /app
RUN rm -rf /mcr-install

# Copy the entrypoint script
COPY entrypoint.sh /app
COPY matlab_decon /app

RUN chmod 755 /app/entrypoint.sh /app/matlab_decon

CMD [ "/app/entrypoint.sh" ]
