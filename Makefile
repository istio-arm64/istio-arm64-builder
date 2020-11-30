export ISTIO_VERSION ?= 1.6.14
export HUB ?= istiojfh
export TAG ?= $(ISTIO_VERSION)
export BUILDER_HUB ?= $(HUB)
export BAZEL_BUILD_ARGS ?= ""
export DOCKER_CLI_EXPERIMENTAL := enabled
ifeq ($(shell uname -m),aarch64)
  export ARCH ?= arm64
else ifeq ($(shell uname -m),x86_64)
  export ARCH ?= amd64
endif

.PHONY: build-tools proxy-builder istio-builder push-builder build-istio cleanup

build-tools: istio-builder proxy-builder

istio-builder:
	docker build -t $(BUILDER_HUB)/istio-builder istio-builder

proxy-builder:
	docker build -t $(BUILDER_HUB)/proxy-builder proxy-builder

push-tools:
	docker buildx build --push --platform linux/amd64,linxu/arm64 -t $(BUILDER_HUB)/istio-builder istio-builder
	docker buildx build --push --platform linux/amd64,linxu/arm64 -t $(BUILDER_HUB)/proxy-builder proxy-builder

build-istio: build/envoy
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		-v ${PWD}/build:/build \
		--env BAZEL_BUILD_ARGS="$(BAZEL_BUILD_ARGS)" \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		$(BUILDER_HUB)/istio-builder bash /usr/local/bin/build.sh

build-proxy: build/envoy

build/envoy:
	mkdir -p build
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		-v ${PWD}/build:/build \
		--env BAZEL_BUILD_ARGS="$(BAZEL_BUILD_ARGS)" \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		$(BUILDER_HUB)/proxy-builder bash /usr/local/bin/build.sh

cleanup:
	docker container prune -f
	docker builder prune -f
	docker image prune -af --filter 'label!=builder'
