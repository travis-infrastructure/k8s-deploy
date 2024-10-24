SHELL := /bin/bash

APP_SOURCE_DIR ?= $(TRAVIS_BUILD_DIR)/src

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
	cd $(TRAVIS_BUILD_DIR) && $(TRAVIS_BUILD_DIR)/flux-release.sh

.PHONY: ship
ship: check-env checkout docker-build
