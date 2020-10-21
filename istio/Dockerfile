FROM ubuntu:18.04

WORKDIR /build

ARG ARCH

ENV GOROOT=/usr/go
ENV GOPATH=/build/go
ENV PATH="${GOROOT}/bin:${PATH}"
ENV TARGET_ARCH=${ARCH}
ENV TARGET_OS=linux
ENV ISTIO_VERSION=1.6.12
ENV HUB=istio
ENV ISTIO_ENVOY_LOCAL=/build/envoy

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    docker.io \
    git \
    make \
    rpm \
    ruby \
    ruby-dev \
    && \
    apt-get clean autoclean autoremove && \
    gem install fpm && \
    curl -L https://golang.org/dl/go1.15.2.linux-${TARGET_ARCH}.tar.gz | tar -xzf - && \
    mv go /usr/ && \
    rm -rf * /var/lib/apt/lists/* /usr/share/doc /usr/share/man usr/share/locale

COPY build.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/build.sh

CMD build.sh
