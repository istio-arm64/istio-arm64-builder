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
export ISTIO_ENVOY_LINUX_RELEASE_PATH=$ISTIO_ENVOY_LOCAL
export ISTIO_ENVOY_CENTOS_LINUX_RELEASE_PATH=$ISTIO_ENVOY_LOCAL
export TARGET_OUT_LINUX="$(pwd)/out/${TARGET_OS}_${TARGET_ARCH}"
export CONTAINER_TARGET_OUT_LINUX=$TARGET_OUT_LINUX
export TAG=${ISTIO_VERSION}-${TARGET_ARCH}
export DOCKER_TARGETS="docker.pilot docker.proxyv2"
export DOCKER_IMGS="pilot proxyv2"
make build

HUB=docker.io/istio TAG=$(grep BASE_VERSION Makefile.core.mk | awk '{print $3;}') make docker.base

if [ $(uname -m) = aarch64 ]; then
	sed -i -e '/amd64/ s/^/#/' Makefile.core.mk
	sed -i -e 's/x86_64/aarch64/g' pilot/docker/Dockerfile.proxyv2
fi
make docker
export DOCKER_CLI_EXPERIMENTAL=enabled
for I in $DOCKER_IMGS; do
	docker push $HUB/$I:$TAG
	if [ $TARGET_ARCH = arm64]; then
		docker pull istio/$I:$ISTIO_VERSION
		docker tag istio/$I:$ISTIO_VERSION $HUB/$I:$ISTIO_VERSION-amd64
		docker push $HUB/$I:$ISTIO_VERSION-amd64
		docker manifest create --amend $HUB/$I:$ISTIO_VERSION $HUB/$I:${ISTIO_VERSION}-amd64 $HUB/$I:${ISTIO_VERSION}-arm64
		docker manifest push --purge $HUB/$I:$ISTIO_VERSION
	fi
done
git checkout .
