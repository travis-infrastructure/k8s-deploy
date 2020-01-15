#!/bin/bash

FLUX_NAMESPACE="flux"
APP_NAME=$(cut -d "/" -f 2 <<< "${K8S_APP_REPO}")
HELM_RELEASE="helmrelease/${APP_NAME}"
DOCKER_IMAGE_REPO="gcr.io/travis-ci-${PROJECT}-services-1/${APP_NAME}"
VERSION_VALUE=$(git --git-dir=/${TRAVIS_BUILD_DIR}/src/.git describe --always --dirty --tags 2>/dev/null)

fluxctl --k8s-fwd-ns=$FLUX_NAMESPACE release \
          --workload gce-$PROJECT-services-1:$HELM_RELEASE \
          --update-image=$DOCKER_IMAGE_REPO:$VERSION_VALUE
