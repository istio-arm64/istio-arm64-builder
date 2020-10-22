export ISTIO_VERSION ?= 1.6.12
export HUB ?= istioarm64
export BUILDER_HUB ?= $(HUB)

.PHONY: build-tools proxy-builder istio-builder push-builder build-istio cleanup

build-tools: proxy-builder istio-builder

proxy-builder: 
	docker build -t $(BUILDER_HUB)/istio-proxy-builder proxy

istio-builder: 
	docker build -t $(BUILDER_HUB)/istio-builder istio

push-builders:
	docker push $(BUILDER_HUB)/istio-proxy-builder
	docker push $(BUILDER_HUB)/istio-builder

build-istio: build-proxy
	mkdir -p build
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		-v ${PWD}/build:/build \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		--env HUB=$(HUB) \
		$(BUILDER_HUB)/istio-builder

build-proxy:
	mkdir -p build
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.docker:/root/.docker \
		-v ${PWD}/build:/build \
		-v ${PWD}/build/bazel:/root/.cache \
		--env ISTIO_VERSION=$(ISTIO_VERSION) \
		$(BUILDER_HUB)/istio-proxy-builder

cleanup:
	rm -rf build
	echo y | docker image prune
	echo y | docker builder prune
	echo y | docker container prune
