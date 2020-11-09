FROM ubuntu:18.04

LABEL builder="true"

WORKDIR /work

ENV GOROOT=/usr/go
ENV GOPATH=/work/out/go
ENV GOCACHE=/work/out/gocache
ENV TARGET_OS=linux
ENV ISTIO_VERSION=1.6.12
ENV HUB=istiojfh

ENV PATH="${GOROOT}/bin:${LLVM_INSTALL}/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
     build-essential \
     curl \
     docker.io \
     git \
     make \
     rpm \
     ruby \
     ruby-dev \
     && \
     apt-get clean && \
     case $(uname -m) in \
         x86_64) export TARGET_ARCH=amd64;; \
         aarch64) export TARGET_ARCH=arm64;; \
         *) echo "cpu NOT in support list"; exit 1 ;; \
     esac && \
     \
     gem install fpm && \
     curl -L https://golang.org/dl/go1.14.9.linux-${TARGET_ARCH}.tar.gz | tar -xzf - && \
     mv go /usr/ && \
     \
     rm -rf * /var/lib/apt/lists/* /usr/share/doc /usr/share/man usr/share/locale

COPY build.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*