#!/bin/bash

set -e

case $(uname -m) in
	x86_64) export TARGET_ARCH=amd64;;
	aarch64) export TARGET_ARCH=arm64;;
	*) echo "cpu NOT in support list"; exit 1 ;;
esac

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
cd proxy
BIN_FULLNAME=istio-proxy-${ISTIO_VERSION}-${TARGET_ARCH}
BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS --verbose_failures -c opt" make build_envoy

cp /work/proxy/bazel-bin/src/envoy/envoy /build/envoy
tar -C /build -czf /build/${BIN_FULLNAME}.tar.gz envoy

