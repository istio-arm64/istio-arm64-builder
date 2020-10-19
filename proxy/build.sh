#!/bin/sh

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
cd proxy
BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS -c opt" make build_envoy
cp bazel-bin/src/envoy/envoy /build
