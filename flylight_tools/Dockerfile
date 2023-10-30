ARG FIJI_VERSION

FROM janeliascicomp/common-tools:1.0.2 as ants-builder
ARG TOOLS_ARCHIVE_RELEASE=1.0.0
ARG ANTS_VERSION=ants-redhat-yuy2013
WORKDIR /tmp
ENV ANTS_FILE=${ANTS_VERSION}.tgz
RUN curl -sLO https://github.com/JaneliaSciComp/tools-archive/releases/download/${TOOLS_ARCHIVE_RELEASE}/${ANTS_FILE} && tar xfz ${ANTS_FILE}

FROM janeliascicomp/common-tools:1.0.2 as vaa3d-builder
ARG TOOLS_ARCHIVE_RELEASE=1.0.0
ARG VAA3D_VERSION=vaa3d-redhat-mark13
WORKDIR /tmp
ENV VAA3D_FILE=${VAA3D_VERSION}.tgz
RUN curl -sLO https://github.com/JaneliaSciComp/tools-archive/releases/download/${TOOLS_ARCHIVE_RELEASE}/${VAA3D_FILE} && tar xfz ${VAA3D_FILE}

FROM janeliascicomp/common-tools:1.0.2 as ffmpeg-builder
ARG TOOLS_ARCHIVE_RELEASE=1.0.0
ARG FFMPEG_VERSION=ffmpeg_20170107
WORKDIR /tmp
ENV FFMPEG_FILE=${FFMPEG_VERSION}.tgz
RUN curl -sLO https://github.com/JaneliaSciComp/tools-archive/releases/download/${TOOLS_ARCHIVE_RELEASE}/${FFMPEG_FILE} && tar xfz ${FFMPEG_FILE}

FROM janeliascicomp/common-tools:1.0.2 as merge-builder
ARG MERGE_VERSION=1.0.0
WORKDIR /tmp
ENV MERGE_FILE=${MERGE_VERSION}.tar.gz
RUN curl -sLO https://github.com/JaneliaSciComp/merge_CMTK/archive/refs/tags/${MERGE_FILE} && tar xfz ${MERGE_FILE} --strip-components=1

FROM janeliascicomp/common-tools:1.0.2 as cmtk-builder
ARG CMTK_VERSION=20171001-sl7avx
ENV CMTK_FILE=cmtk-${CMTK_VERSION}.tgz
WORKDIR /tmp/cmtk
RUN curl -sLO https://github.com/JaneliaSciComp/tools-archive/releases/download/1.0.0/${CMTK_FILE} && tar xfz ${CMTK_FILE} --strip-components=1

FROM janeliascicomp/common-tools:1.0.2 as conda-builder
WORKDIR /app

RUN curl -sL https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN /opt/conda/bin/conda update conda -y \
    && /opt/conda/bin/conda create -n py3 python=3 h5py=2.8.0 PyYAML=3.13 -y \
    && /opt/conda/bin/conda clean --all -f -y

# Start with Fiji
FROM janeliascicomp/fiji-zulu-8:$FIJI_VERSION
ARG VAA3D_VERSION
ARG FFMPEG_VERSION

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
        libxext6 libxrender1 libxtst6 libxi6 libglu1-mesa qt4-default libqt4-opengl libxv-dev \
        numactl rsync pbzip2 net-tools xvfb netpbm imagemagick libfftw3-double3

COPY --from=ants-builder --chown=root:root /tmp/ANTS /app/ants
COPY --from=vaa3d-builder --chown=root:root /tmp/$VAA3D_VERSION /app/vaa3d
COPY --from=ffmpeg-builder --chown=root:root /tmp/$FFMPEG_VERSION/ /app/ffmpeg/
COPY --from=conda-builder --chown=root:root /opt/conda /opt/conda
COPY --from=cmtk-builder --chown=root:root /tmp/cmtk /app/cmtk

COPY scripts /app/scripts
COPY fiji_macros /app/fiji_macros
COPY fiji_plugins /app/fiji/Fiji.app/plugins
COPY fiji_luts /app/fiji/Fiji.app/luts

COPY --from=merge-builder --chown=root:root /tmp/*.sh /app/scripts/cmd
COPY --from=merge-builder --chown=root:root /tmp/plugins/* /app/fiji/Fiji.app/plugins
COPY --from=merge-builder --chown=root:root /tmp/*.ijm /app/fiji_macros

WORKDIR /app

# No entrypoint so that the user can invoke whatever script they need
ENTRYPOINT []

