FROM scientificlinux/sl:7

ENV COMMON_TOOLS_DIR=/opt/common-tools
ENV FB_MODE=

ENV PATH=${PATH}:${COMMON_TOOLS_DIR}

RUN yum install -y epel-release \
    && yum install -y net-tools libX11-devel Xvfb ImageMagick tree jq bc python-pip \
    && pip install --upgrade pip \
    && pip install yq

COPY --chown=root:root scripts ${COMMON_TOOLS_DIR}
