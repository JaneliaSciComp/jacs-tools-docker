FROM scientificlinux/sl:7

COPY scripts /opt/common-tools

ENV COMMON_TOOLS_DIR=/opt/common-tools
ENV FB_MODE=

ENV PATH=${PATH}:${COMMON_TOOLS_DIR}

RUN echo "Installing OS updates"
ENV EPEL_FILE=epel-release-latest-7.noarch.rpm
RUN curl -s http://dl.fedoraproject.org/pub/epel/${EPEL_FILE} -o '#1'
RUN rpm -ivh $EPEL_FILE && /bin/rm -f $EPEL_FILE
RUN yum install -y \
    net-tools \
    libX11-devel Xvfb \
    tree \
    jq bc \
    python-pip
RUN pip install --upgrade pip

RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
