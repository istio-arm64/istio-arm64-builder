## Build istio releases for arm64
### This box will do the following:
1. Create build directory in **$PWD**, download istio and proxy source code.
2. Call **make build_envoy** to build the proxy to build/envoy.
3. Call **make build** to build istio binaries.
4. Call make **docker.push** to build istio docker images and push them.
### Prerequisites:
1. A 16C32G arm64 vm is prefered, I did try to build in a 2C4G vm, clang was OOM-killed.
2. Docker installed.
3. docker login before calling make
4. It is known to work in Linux or Mac OS.
### Usage:
1. Build the builder images: 
```
make build-tools
```
2. Build istio, you can specify the version to be built, and also HUB/BUILDER_HUB can be overrided :
```
ISTIO_VERSION=1.7.3 HUB=istioarm64 make build-istio
```
3. Cleanup build directory, docker builder caches and so on.
```
make cleanup
```
