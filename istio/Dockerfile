FROM ubuntu:18.04

WORKDIR /build

ENV GOROOT=/usr/go
ENV GOPATH=/build/go
ENV PATH="${GOROOT}/bin:${PATH}"
ENV TARGET_OS=linux
ENV ISTIO_VERSION=1.6.12
ENV HUB=istio
ENV ISTIO_ENVOY_LOCAL=/build/envoy

COPY build.sh /usr/local/bin/

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
    case $(uname -m) in \
         x86_64) export TARGET_ARCH=amd64;; \
         aarch64) export TARGET_ARCH=arm64;; \
         *) echo "cpu NOT in support list"; exit 1 ;; \
     esac && \
    gem install fpm && \
    curl -L https://golang.org/dl/go1.15.2.linux-${TARGET_ARCH}.tar.gz | tar -xzf - && \
    mv go /usr/ && \
    rm -rf * /var/lib/apt/lists/* /usr/share/doc /usr/share/man usr/share/locale && \
    chmod +x /usr/local/bin/*

CMD build.sh
