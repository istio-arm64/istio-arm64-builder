export ISTIO_VERSION ?= 1.6.13
export HUB ?= istioarm64
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

build-tools: 
	docker build -t $(BUILDER_HUB)/build-tools-$(ARCH) build-tools
	docker push $(BUILDER_HUB)/build-tools-$(ARCH)
	docker manifest create --amend $(BUILDER_HUB)/build-tools $(BUILDER_HUB)/build-tools-amd64 $(BUILDER_HUB)/build-tools-arm64
	docker manifest push --purge $(BUILDER_HUB)/build-tools

push-tools:
	docker push $(BUILDER_HUB)/build-tools

build-istio:
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		--env BAZEL_BUILD_ARGS="$(BAZEL_BUILD_ARGS)" \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		$(BUILDER_HUB)/build-tools bash /usr/local/bin/build.sh

cleanup:
	bash -c "docker container prune <<< y"
	bash -c "docker builder prune <<< y"
	bash -c "docker image prune -a --filter 'label!=builder' <<< y"
