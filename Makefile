export ISTIO_VERSION ?= 1.6.12
export HUB ?= istioarm64
export BUILDER_HUB ?= $(HUB)
export BAZEL_BUILD_ARGS ?= ""

.PHONY: build-tools proxy-builder istio-builder push-builder build-istio cleanup

build-tools: 
	docker buildx build --load --platform linux/arm64 -t $(BUILDER_HUB)/build-tools build-tools

push-tools:
	docker push $(BUILDER_HUB)/build-tools

build-istio:
	mkdir -p build
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		--env BAZEL_BUILD_ARGS="$(BAZEL_BUILD_ARGS)" \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		$(BUILDER_HUB)/build-tools build.sh

cleanup:
	rm -rf build
	bash -c "docker image prune <<< y"
	bash -c "docker builder prune <<< y"
	bash -c "docker container prune <<< y"
