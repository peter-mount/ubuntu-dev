FROM ubuntu:16.04
MAINTAINER Peter Mount <peter@retep.org>

# Java Version - Based on jeanblanchard/jdk
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 92
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk

# Update apt. Unlike most builds we will keep this in place
RUN apt-get update &&\
    apt-get install -y \
        apt-transport-https \
        ca-certificates &&\
    mkdir -p /opt

# Core shell commands
RUN apt-get install -y \
        curl \
        s3cmd \
        sudo \
        unzip \
	vim \
	zip

# C tools
RUN apt-get install -y \
        aufs-tools \
        autoconf \
        automake \
        build-essential \
        libcurl4-openssl-dev

# Version control
RUN apt-get install -y \
        cvs \
        git \
        mercurial \
        reprepro \
        subversion

# Java
RUN curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" \
        -o java.tar.gz\
        http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz &&\
    gunzip -c java.tar.gz | tar -xf - -C /opt && rm -f java.tar.gz &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
        /opt/jdk/lib/missioncontrol \
        /opt/jdk/lib/visualvm \
        /opt/jdk/lib/*javafx* \
        /opt/jdk/jre/lib/plugin.jar \
        /opt/jdk/jre/lib/ext/jfxrt.jar \
        /opt/jdk/jre/bin/javaws \
        /opt/jdk/jre/lib/javaws.jar \
        /opt/jdk/jre/lib/desktop \
        /opt/jdk/jre/plugin \
        /opt/jdk/jre/lib/deploy* \
        /opt/jdk/jre/lib/*javafx* \
        /opt/jdk/jre/lib/*jfx* \
        /opt/jdk/jre/lib/amd64/libdecora_sse.so \
        /opt/jdk/jre/lib/amd64/libprism_*.so \
        /opt/jdk/jre/lib/amd64/libfxplugins.so \
        /opt/jdk/jre/lib/amd64/libglass.so \
        /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
        /opt/jdk/jre/lib/amd64/libjavafx*.so \
        /opt/jdk/jre/lib/amd64/libjfx*.so &&\
    sed -e "s|export PATH=|export PATH=/opt/jdk/bin:|" -i /etc/profile &&\
    curl -s https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem -o /lets-encrypt-x1-cross-signed.pem &&\
    curl -s https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.pem -o /lets-encrypt-x2-cross-signed.pem &&\
    curl -s https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -o /lets-encrypt-x3-cross-signed.pem &&\
    curl -s https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem -o /lets-encrypt-x4-cross-signed.pem &&\
    /opt/jdk/bin/keytool \
        -trustcacerts -keystore /opt/jdk/jre/lib/security/cacerts \
        -storepass changeit -noprompt -importcert \
        -alias lets-encrypt-x1-cross-signed \
        -file /lets-encrypt-x1-cross-signed.pem &&\
    /opt/jdk/bin/keytool \
        -trustcacerts -keystore /opt/jdk/jre/lib/security/cacerts \
        -storepass changeit -noprompt -importcert \
        -alias lets-encrypt-x2-cross-signed \
        -file /lets-encrypt-x2-cross-signed.pem &&\
    /opt/jdk/bin/keytool -trustcacerts -keystore /opt/jdk/jre/lib/security/cacerts \
        -storepass changeit -noprompt -importcert \
        -alias lets-encrypt-x3-cross-signed \
        -file /lets-encrypt-x3-cross-signed.pem &&\
    /opt/jdk/bin/keytool \
        -trustcacerts -keystore /opt/jdk/jre/lib/security/cacerts \
        -storepass changeit -noprompt -importcert \
        -alias lets-encrypt-x4-cross-signed \
        -file /lets-encrypt-x4-cross-signed.pem &&\
    rm -f /*.pem

# Don't clean up apt as we can use that as part of dev build jobs later otherwise they'll need to run apt-get update each time
#    rm -rf /var/lib/apt/lists/*
