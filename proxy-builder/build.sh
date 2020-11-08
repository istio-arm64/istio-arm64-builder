#!/bin/bash

set -e

git clone --depth=1 -b $ISTIO_VERSION https://github.com/istio/proxy.git
cd proxy
SHA1=$(git rev-parse HEAD)
BAZEL_BUILD_ARGS="$BAZEL_BUILD_ARGS -c opt" make build_envoy

