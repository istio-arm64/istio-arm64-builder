#!/bin/bash

set -e

case $(uname -m) in
	x86_64) export TARGET_ARCH=amd64;;
	aarch64) export TARGET_ARCH=arm64;;
	*) echo "cpu NOT in support list"; exit 1 ;;
esac

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
export CC=clang
export CXX=clang++
cd proxy
REV=$(git rev-parse $ISTIO_VERSION)

BAZEL_OUT="$(bazel info $BAZEL_BUILD_ARGS -c opt output_path)/k8-opt/bin"
BAZEL_TARGET="${BAZEL_OUT}/src/envoy/envoy_tar.tar.gz"
BIN_FULLNAME=istio-proxy-${ISTIO_VERSION}-${TARGET_ARCH}
bazel build ${BAZEL_BUILD_ARGS} --config=libc++ --config=release -c opt //src/envoy:envoy_tar
cp -f "${BAZEL_TARGET}" /build/envoy-${REV}.tar.gz

if [[ $ISTIO_VERSION =~ ^1\.8 ]]; then
	rm -rf ~/.cache
  BAZEL_OUT="$(bazel info $BAZEL_BUILD_ARGS -c opt --cxxopt -D_GLIBCXX_USE_CXX11_ABI=1 --cxxopt -DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1 output_path)/k8-opt/bin"
	BAZEL_TARGET="${BAZEL_OUT}/src/envoy/envoy_tar.tar.gz"
	CENTOS_BIN_FULLNAME=istio-proxy-centos-${ISTIO_VERSION}-${TARGET_ARCH}
	bazel build ${BAZEL_BUILD_ARGS} --config=libc++ --config=release -c opt --cxxopt -D_GLIBCXX_USE_CXX11_ABI=1 --cxxopt -DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1 //src/envoy:envoy_tar
	cp -f "${BAZEL_TARGET}" /build/envoy-centos-${REV}.tar.gz
fi