FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y curl

# install Matlab-2017a
WORKDIR /c3d-download

RUN curl -sSL "http://downloads.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz" \
    | tar -xvz
RUN cp -a /c3d-download/c3d-1.0.0-Linux-x86_64/* /usr/local

WORKDIR /app
RUN rm -rf /c3d-download

# Copy the entrypoint script
COPY entrypoint.sh /app

RUN chmod 755 /app/entrypoint.sh

CMD [ "/app/entrypoint.sh" ]
