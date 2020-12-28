# Checkout from private SAGE repo
FROM ubuntu:18.04 as builder

# Install Perl modules
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-client git cpanminus make
RUN cpanm JSYNC Switch Class::Accessor Image::Size Kafka::Connection

# Add SSH credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install SAGE scripts
WORKDIR /app
RUN git clone git@github.com:JaneliaSciComp/SAGE.git

# Create final image
FROM ubuntu:18.04

# eliminate input warnings from debconf
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends -y libdbd-mysql-perl

WORKDIR /app
COPY --from=builder /usr/local/lib/x86_64-linux-gnu/perl /usr/local/lib/x86_64-linux-gnu/perl
COPY --from=builder /usr/local/share/perl /usr/local/share/perl
COPY --from=builder /usr/share/perl /usr/share/perl
COPY --from=builder /usr/lib/x86_64-linux-gnu/perl /usr/lib/x86_64-linux-gnu/perl
COPY --from=builder /app/SAGE /app/SAGE
COPY Zeiss/ /usr/share/perl5/Zeiss
COPY scripts /app/scripts

