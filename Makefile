export ISTIO_VERSION ?= 1.6.12
export HUB ?= istioarm64
export TAG ?= $(ISTIO_VERSION)
export BUILDER_HUB ?= $(HUB)
export BAZEL_BUILD_ARGS ?= ""

.PHONY: build-tools proxy-builder istio-builder push-builder build-istio cleanup

build-tools: 
	docker buildx build --push --platform linux/arm64 -t $(BUILDER_HUB)/build-tools build-tools

push-tools:
	docker push $(BUILDER_HUB)/build-tools

build-istio:
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		--env BAZEL_BUILD_ARGS="$(BAZEL_BUILD_ARGS)" \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		--env TAG=$(TAG) \
		$(BUILDER_HUB)/build-tools build.sh

cleanup:
	bash -c "docker container prune <<< y"
	bash -c "docker builder prune <<< y"
	bash -c "docker image prune -a --filter 'label!=builder' <<< y"
