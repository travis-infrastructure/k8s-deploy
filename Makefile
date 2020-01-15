SHELL := bash

VERSION_VALUE ?= $(shell git describe --always --dirty --tags 2>/dev/null)
APP_NAME ?= $(shell gcut -d "/" -f 2 <<< "${K8S_APP_REPO}")
DOCKER_IMAGE_REPO ?= gcr.io/travis-ci-$(PROJECT)-services-1/$(APP_NAME)
FLUX_NAMESPACE ?= flux
HELM_RELEASE ?= helmrelease/$(APP_NAME)
APP_SOURCE_DIR ?= $(TRAVIS_BUILD_DIR)/src
FLUXCTL ?= fluxctl

.PHONY: check-env
check-env:
ifndef K8S_APP_REPO
	$(error K8S_APP_REPO is undefined)
endif
ifndef PROJECT
	$(error PROJECT is undefined)
endif

.PHONY: checkout
checkout:
	$(TRAVIS_BUILD_DIR)/checkout.sh

.PHONY: docker-build
docker-build:
	cd $(APP_SOURCE_DIR) && $(TRAVIS_BUILD_DIR)/docker-build.sh

.PHONY: flux-release
flux-release:
	$(FLUXCTL) --k8s-fwd-ns=$(FLUX_NAMESPACE) release --workload gce-$(PROJECT)-services-1:$(HELM_RELEASE) --update-image=$(DOCKER_IMAGE_REPO):$(VERSION_VALUE)

.PHONY: ship
ship: check-env checkout docker-build flux-release
