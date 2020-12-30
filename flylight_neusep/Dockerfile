ARG VAA3D_VERSION=redhat-mark13
ARG VAA3D_IMAGE=janeliascicomp/vaa3d:$VAA3D_VERSION

FROM janeliascicomp/common-tools:1.0.2 as builder
ARG TOOLS_ARCHIVE_RELEASE=1.0.0
ARG NEUSEP_VERSION=neusep_4.11-sl72-bin

WORKDIR /tmp
ENV TOOLS_ARCHIVE_URL=https://github.com/JaneliaSciComp/tools-archive/releases/download/${TOOLS_ARCHIVE_RELEASE}
ENV NEUSEP_FILE=${NEUSEP_VERSION}.tgz
RUN curl -sLO ${TOOLS_ARCHIVE_URL}/${NEUSEP_FILE} && tar xvfz ${NEUSEP_FILE}

FROM $VAA3D_IMAGE
ARG NEUSEP_VERSION

# install dependencies
RUN yum install -y pbzip2 netpbm netpbm-progs

COPY --from=builder --chown=root:root /tmp/$NEUSEP_VERSION/ /app/neusep
COPY scripts /app/scripts

WORKDIR /app

# No entrypoint so that the user can invoke whatever script they need
ENTRYPOINT []

