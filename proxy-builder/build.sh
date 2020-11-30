#!/bin/bash

set -e

case $(uname -m) in
	x86_64) export TARGET_ARCH=amd64;;
	aarch64) export TARGET_ARCH=arm64;;
	*) echo "cpu NOT in support list"; exit 1 ;;
esac

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
cd proxy
REV=$(git rev-parse $ISTIO_VERSION)

BIN_FULLNAME=istio-proxy-${ISTIO_VERSION}-${TARGET_ARCH}
BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS -c opt" make build_envoy
cp /work/proxy/bazel-bin/src/envoy/envoy /build/envoy
cp /build/envoy /build/envoy-$REV
tar -C /build -czf /build/${BIN_FULLNAME}.tar.gz envoy

if [[ $ISTIO_VERSION =~ ^1\.8 ]]; then
	CENTOS_BIN_FULLNAME=istio-proxy-centos-${ISTIO_VERSION}-${TARGET_ARCH}
	BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS -c opt --cxxopt -D_GLIBCXX_USE_CXX11_ABI=1 --cxxopt -DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1" BUILD_ENVOY_BINARY_ONLY=1 BASE_BINARY_NAME=envoy-centos make build_envoy
	cp /work/proxy/bazel-bin/src/envoy/envoy-centos /build/envoy-centos
	cp /build/envoy-centos /build/envoy-centos-$REV
	tar -C /build -czf /build/${CENTOS_BIN_FULLNAME}.tar.gz envoy-centos
fi