FROM scientificlinux/sl:7


COPY fiji_macros /opt/fiji_macros
COPY fiji_plugins /opt/fiji_plugins
COPY fiji_luts /opt/fiji_luts
COPY scripts /opt/app-scripts

RUN chmod 755 /opt/app-scripts/*.sh

RUN echo "Installing dependencies"
ENV EPEL_FILE=epel-release-latest-7.noarch.rpm
RUN curl -s http://dl.fedoraproject.org/pub/epel/${EPEL_FILE} -o '#1'
RUN rpm -ivh $EPEL_FILE && /bin/rm -f $EPEL_FILE
RUN yum install -y python-pip jq bc
RUN pip install --upgrade pip

WORKDIR /opt

RUN yum install -y net-tools libX11-devel Xvfb 

RUN echo "Installing Fiji"
# Prereqs for Fiji
RUN yum install -y libXtst-devel libXrender

# Install Fiji
ENV FIJI_FILE=fiji-1.52c.tgz
RUN curl -s http://workstation.int.janelia.org/files/fiji/${FIJI_FILE} -o ${FIJI_FILE}
RUN tar xvf $FIJI_FILE && /bin/rm -rf $FIJI_FILE
RUN rm -rf Fiji
RUN mv Fiji.app Fiji


RUN echo "Installing Fiji plugins"
ENV PLUGINS_SOURCE=/opt/fiji_plugins
ENV PLUGINS_TARGET=/opt/Fiji/plugins
RUN cp -R $PLUGINS_SOURCE/* $PLUGINS_TARGET && /bin/rm -rf $PLUGINS_SOURCE

RUN echo "Installing Fiji LUTs for color depth"
ENV LUTS_SOURCE=/opt/fiji_luts
ENV LUTS_TARGET=/opt/Fiji/luts
RUN cp -R $LUTS_SOURCE/* $LUTS_TARGET && /bin/rm -rf $LUTS_SOURCE
