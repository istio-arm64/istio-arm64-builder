#!/bin/bash

set -e

case $(uname -m) in 
	x86_64) export TARGET_ARCH=amd64;;
	aarch64) export TARGET_ARCH=arm64;;
	*) echo "cpu NOT in support list"; exit 1 ;;
esac

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/istio.git

cd istio

export BUILD_WITH_CONTAINER=0
export USE_LOCAL_PROXY=1
export ISTIO_ENVOY_LOCAL=/build/envoy
export ISTIO_ENVOY_LOCAL_PATH=$ISTIO_ENVOY_LOCAL
export TARGET_OUT_LINUX="$(pwd)/out/${TARGET_OS}_${TARGET_ARCH}"
export CONTAINER_TARGET_OUT_LINUX=$TARGET_OUT_LINUX
export TAG=${ISTIO_VERSION}-${TARGET_ARCH}

make build

HUB=docker.io/istio TAG=$(grep BASE_VERSION Makefile.core.mk | awk '{print $3;}') make docker.base

if [ $(uname -m) = aarch64 ]; then
	sed -i -e '/amd64/ s/^/#/' Makefile.core.mk
	sed -i -e 's/x86_64/aarch64/g' pilot/docker/Dockerfile.proxyv2
fi
make docker
export DOCKER_CLI_EXPERIMENTAL=enabled
docker images | grep $TAG | awk '{print $1" "$2;}' | \
while read I T; do
  docker push $I:$T
  docker manifest create --amend $I:$ISTIO_VERSION $I:${ISTIO_VERSION}-amd64 $I:${ISTIO_VERSION}-arm64 && \
	  docker manifest push --purge $I:$ISTIO_VERSION || \
	  echo ignore docker manifest error.
done
git checkout .
