FROM scientificlinux/sl:7

COPY aligner /opt/aligner
COPY color_depth /opt/color_depth
COPY scripts /opt/aligner-scripts

RUN chmod 755 /opt/aligner/*.sh
RUN chmod 755 /opt/aligner-scripts/*.sh

ENV FB_MODE=

RUN echo "Installing dependencies"
ENV EPEL_FILE=epel-release-latest-7.noarch.rpm
RUN curl -s http://dl.fedoraproject.org/pub/epel/{$EPEL_FILE} -o '#1'
RUN rpm -ivh $EPEL_FILE && /bin/rm -f $EPEL_FILE
RUN yum install -y python-pip jq bc tree
RUN pip install --upgrade pip
RUN pip install yq

RUN echo "Installing S3 FUSE and AWS CLI"
RUN yum install -y fuse-devel s3fs-fuse awscli

ENV S3_TEMPLATES_MOUNTPOINT=/data/s3/templates

RUN mkdir -p ${S3_TEMPLATES_MOUNTPOINT}

WORKDIR /opt

RUN yum install -y net-tools libX11-devel Xvfb 

RUN echo "Installing Vaa3d"
# Prereqs for Vaa3d
RUN yum install -y mesa-libGLU qt qt-x11 libXv numactl-libs

# Install Vaa3d
ENV VAA3D_FILE=vaa3d-redhat-mark10.tgz
RUN curl -s http://workstation.int.janelia.org/files/tools/${VAA3D_FILE} -o ${VAA3D_FILE}
RUN tar xvf ${VAA3D_FILE} && /bin/rm -f ${VAA3D_FILE}
RUN ln -s /opt/vaa3d-redhat-mark10 Vaa3D

RUN echo "Installing Fiji"
# Prereqs for Fiji
RUN yum install -y libXtst-devel libXrender
# Install Fiji
ENV FIJI_FILE=fiji-1.52c.tgz
RUN curl -s http://workstation.int.janelia.org/files/fiji/{$FIJI_FILE} -o ${FIJI_FILE}
RUN tar xvf $FIJI_FILE && /bin/rm -rf $FIJI_FILE
RUN rm -rf Fiji
RUN mv Fiji.app Fiji

RUN echo "Installing Fiji plugins for the aligner"
ENV PLUGINS_SOURCE=/opt/aligner/fiji_plugins
ENV PLUGINS_TARGET=/opt/Fiji/plugins
RUN cp -R $PLUGINS_SOURCE/* $PLUGINS_TARGET && /bin/rm -rf $PLUGINS_SOURCE
RUN echo "Installing Fiji plugins for color depth"
ENV PLUGINS_SOURCE=/opt/color_depth/fiji_plugins
RUN cp -R $PLUGINS_SOURCE/* $PLUGINS_TARGET && /bin/rm -rf $PLUGINS_SOURCE

RUN echo "Installing Fiji LUTs for color depth"
ENV LUTS_SOURCE=/opt/color_depth/fiji_luts
ENV LUTS_TARGET=/opt/Fiji/luts
RUN cp -R $LUTS_SOURCE/* $LUTS_TARGET && /bin/rm -rf $LUTS_SOURCE

RUN echo "Installing CMTK"
# Prereqs for CMTK
RUN yum install -y fftw-libs-double
# Install CMTK
ENV CMTK_FILE=cmtk-20171001-sl7avx.tgz
RUN curl -s http://workstation.int.janelia.org/files/tools/{$CMTK_FILE} -o '#1'
RUN tar xvf $CMTK_FILE && /bin/rm -f $CMTK_FILE
RUN ln -s cmtk-scm-2017-10-01 CMTK

RUN echo "Fixing permissions"
RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
