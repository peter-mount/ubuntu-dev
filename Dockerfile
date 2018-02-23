ARG ubuntuVersion=18.04
FROM ubuntu:${ubuntuVersion}
MAINTAINER Peter Mount <peter@retep.org>

# Update apt. Unlike most builds we will keep this in place
RUN apt-get update &&\
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        libcurl4-openssl-dev \
        s3cmd \
        sudo \
        unzip \
        vim \
        zip \
        aufs-tools \
        autoconf \
        automake \
        build-essential \
        cvs \
        git \
        mercurial \
        reprepro \
        subversion
