FROM ubuntu:18.04 AS gn

WORKDIR /work

RUN  apt-get update && apt-get install -y --no-install-recommends ca-certificates git clang python ninja-build libclang-dev libc++-dev && \
     \
     git clone https://gn.googlesource.com/gn && \
     cd gn && \
     git checkout 501b49a3 && \
     python build/gen.py && \
     ninja -v -C out && \
     out/gn_unittests

FROM ubuntu:18.04

LABEL builder="true"

WORKDIR /work

ENV LLVM_VERSION=9.0.1
ENV LLVM_INSTALL=/usr/lib/llvm-9

ENV GOROOT=/usr/go
ENV GOPATH=/work/out/go
ENV GOCACHE=/work/out/gocache
ENV TARGET_OS=linux
ENV ISTIO_VERSION=1.6.12
ENV HUB=istio

ENV PATH="${GOROOT}/bin:${LLVM_INSTALL}/bin:${PATH}"

COPY --from=gn /work/gn/out/gn /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
     autoconf \
     automake \
     build-essential \
     cmake \
     curl \
     docker.io \
     git \
     libtool \
     make \
     ninja-build \
     openjdk-11-jdk \
     patch \
     python \
     rpm \
     ruby \
     ruby-dev \
     unzip \
     virtualenv \
     xz-utils \
     && \
     apt-get clean autoclean autoremove && \
     case $(uname -m) in \
         x86_64) export TARGET_ARCH=amd64; export LLVM_PKG=clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04;; \
         aarch64) export TARGET_ARCH=arm64; export LLVM_PKG=clang+llvm-${LLVM_VERSION}-aarch64-linux-gnu;; \
         *) echo "cpu NOT in support list"; exit 1 ;; \
     esac && \
     \
     curl -L "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${LLVM_PKG}.tar.xz" | tar -xJf - && \
     mkdir -p ${LLVM_INSTALL} && \
     mv ${LLVM_PKG}/* ${LLVM_INSTALL}/ && \
     echo "${LLVM_INSTALL}/lib" > /etc/ld.so.conf.d/llvm.conf && ldconfig && \
     \
     case $(uname -m) in \
        x86_64) export BAZEL_DOWNLOAD_URL=https://github.com/bazelbuild/bazelisk/releases/download/v1.7.2/bazelisk-linux-amd64;; \
        aarch64) export BAZEL_DOWNLOAD_URL=https://github.com/Tick-Tocker/bazelisk-arm64/releases/download/arm64/bazelisk-linux-arm64;; \
        *) echo "cpu NOT in support list"; exit 1 ;; \
     esac && \
     gem install fpm && \
     curl -L https://golang.org/dl/go1.14.9.linux-${TARGET_ARCH}.tar.gz | tar -xzf - && \
     mv go /usr/ && \
     \
     curl -L -o /usr/local/bin/bazel ${BAZEL_DOWNLOAD_URL} && \
     chmod +x /usr/local/bin/* && \
     \
     rm -rf * /var/lib/apt/lists/* /usr/share/doc /usr/share/man usr/share/locale

COPY build.sh /usr/local/bin/
