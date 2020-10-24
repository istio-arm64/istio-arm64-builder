#!/bin/bash

set -e

case $(uname -m) in 
	x86_64) export TARGET_ARCH=amd64;;
	aarch64) export TARGET_ARCH=arm64;;
	*) echo "cpu NOT in support list"; exit 1 ;;
esac

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
cd proxy
BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS -c opt" make build_envoy

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/istio.git

cd istio

export BUILD_WITH_CONTAINER=0
export USE_LOCAL_PROXY=1
export ISTIO_ENVOY_LOCAL=/work/proxy/bazel-bin/src/envoy/envoy
export ISTIO_ENVOY_LOCAL_PATH=$ISTIO_ENVOY_LOCAL
export TARGET_OUT_LINUX="$(pwd)/out/${TARGET_OS}_${TARGET_ARCH}"
export CONTAINER_TARGET_OUT_LINUX=$TARGET_OUT_LINUX
if [ "x$TAG" = "x" ]; then
	export TAG=${ISTIO_VERSION}-${TARGET_ARCH}
fi

make build

HUB=docker.io/istio TAG=$(grep BASE_VERSION Makefile.core.mk | awk '{print $3;}') make docker.base

if [ $(uname -m) = aarch64 ]; then
	sed -i -e '/amd64/ s/^/#/' Makefile.core.mk
	sed -i -e 's/x86_64/aarch64/g' pilot/docker/Dockerfile.proxyv2
fi
make docker.push

git checkout .
