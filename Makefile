SHELL := bash

VERSION_VALUE ?= $(shell git describe --always --dirty --tags 2>/dev/null)
DOCKER_IMAGE_REPO ?= gcr.io/travis-ci-staging-services-1/test-google-sdk
FLUX_NAMESPACE ?= flux
APP_NAMESPACE ?= gce-staging-services-1
HELM_RELEASE ?= helmrelease/shield

DOCKER ?= gcloud docker --
FLUXCTL ?= fluxctl

.PHONY: docker-build
docker-build:
	$(DOCKER) build . -t $(DOCKER_IMAGE_REPO):$(VERSION_VALUE)

.PHONY: docker-push
docker-push:
	$(DOCKER) push $(DOCKER_IMAGE_REPO):$(VERSION_VALUE)

.PHONY: flux-release
flux-release:
	$(FLUXCTL) --k8s-fwd-ns=$(FLUX_NAMESPACE) release --workload $(APP_NAMESPACE):$(HELM_RELEASE) --update-image=$(DOCKER_IMAGE_REPO):$(VERSION_VALUE)

.PHONY: ship
ship: docker-build docker-push flux-release
