#!/bin/sh

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/istio.git

cd istio
export BUILD_WITH_CONTAINER=0
export USE_LOCAL_PROXY=1
export ISTIO_ENVOY_LOCAL_PATH=$ISTIO_ENVOY_LOCAL
export TARGET_OUT_LINUX="$(pwd)/out/${TARGET_OS}_${TARGET_ARCH}"
export CONTAINER_TARGET_OUT_LINUX=$TARGET_OUT_LINUX
if [ "x$TAG" = "x" ]; then
	export TAG=$ISTIO_VERSION
fi

make build

make docker.base
docker tag ${HUB}/base:$ISTIO_VERSION docker.io/istio/base:$(grep BASE_VERSION Makefile.core.mk | awk '{print $3;}')

if [ $(uname -m) = aarch64 ]; then
	sed -i -e '/amd64/ s/^/#/' Makefile.core.mk
	sed -i -e 's/x86_64/aarch64/g' pilot/docker/Dockerfile.proxyv2
fi
make docker.push

git checkout .
