FROM ubuntu:18.04 as builder

LABEL maintainer="Rob Svirskas <svirskasr@hhmi.org>"
LABEL description="SAGE Loader and other Perl scripts"

# Install dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y perl openssh-client git \
        make libyaml-appconfig-perl build-essential \
        libexpat-dev libxml-sax-expat-incremental-perl \
        libpq5 libpq-dev libdbd-pg-perl libmysqlclient-dev libdbd-mysql-perl

# Install Perl modules
RUN cpan App::cpanminus \
    && cpanm DBI Digest::MD5 Fcntl File::Basename \
         Getopt::Long Image::Size IO::File JSON LWP::UserAgent LWP::Simple \
         Parse::RecDescent Pod::Text Pod::Usage POSIX Scalar::Util \
         Switch Sys::Hostname Time Try::Tiny URI::Escape XML::Simple \
         CGI Class::Accessor::Fast Date::Calc Date::Manip \
         Rose::DB::Object::Manager DBD::Pg DBD::mysql

# Add SSH credentials
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install SAGE scripts
WORKDIR /app
RUN git clone git@github.com:JaneliaSciComp/SAGE.git

# Install Perl modules
COPY modules /usr/share/perl5

# Create final image
FROM ubuntu:18.04

# Eliminate input warnings from debconf
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
    && apt-get install -y libexpat-dev libxml-sax-expat-incremental-perl \
    libpq5 libpq-dev libdbd-pg-perl libmysqlclient-dev libdbd-mysql-perl \
    sendmail

# Python (needed for PTR and FFC)
RUN apt-get install -y python3-pip python3-dev libmysqlclient-dev \
    && pip3 --no-cache-dir install --upgrade pip \
    && pip3 install mysqlclient \
    && ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app
COPY --from=builder /usr/share/perl /usr/share/perl
COPY --from=builder /usr/share/perl5 /usr/share/perl5
COPY --from=builder /usr/local/share/perl /usr/local/share/perl
COPY --from=builder /usr/local/lib/x86_64-linux-gnu/perl /usr/local/lib/x86_64-linux-gnu/perl
COPY --from=builder /usr/lib/x86_64-linux-gnu/perl /usr/lib/x86_64-linux-gnu/perl
COPY --from=builder /app/SAGE /app/SAGE
COPY scripts /app/scripts
RUN mkdir -p /groups
RUN mkdir -p /misc/sc/pipeline

