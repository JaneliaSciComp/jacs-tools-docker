FROM scientificlinux/sl:7

ENV COMMON_TOOLS_DIR=/opt/common-tools
ENV FB_MODE=

ENV PATH=${PATH}:${COMMON_TOOLS_DIR}

RUN echo "Installing OS updates"
RUN yum install -y epel-release
RUN yum install -y \
    net-tools \
    libX11-devel Xvfb ImageMagick \
    tree \
    jq bc \
    python-pip
RUN pip install --upgrade pip
RUN pip install yq

COPY scripts ${COMMON_TOOLS_DIR}

RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
