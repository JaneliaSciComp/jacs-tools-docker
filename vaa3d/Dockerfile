FROM janeliascicomp/common-tools:1.0.2 as builder
ARG TOOLS_ARCHIVE_RELEASE=1.0.0
ARG GIT_TAG=vaa3d-redhat-mark13

WORKDIR /tmp
ENV VAA3D_FILE=$GIT_TAG.tgz
RUN curl -sLO https://github.com/JaneliaSciComp/tools-archive/releases/download/${TOOLS_ARCHIVE_RELEASE}/${VAA3D_FILE} && tar xfz ${VAA3D_FILE}

FROM janeliascicomp/common-tools:1.0.2
ARG GIT_TAG

# Prereqs for Vaa3d
RUN yum install -y mesa-libGLU qt qt-x11 libXv numactl-libs

COPY --from=builder --chown=root:root /tmp/$GIT_TAG/ /app/vaa3d/

ENTRYPOINT [ "/app/vaa3d/vaa3d" ]
