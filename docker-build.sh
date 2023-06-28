#!/bin/bash

set -o errexit
set -xv

#
# This script checks if image already exist in registry, if not it will build and tag image
#

APP_NAME=$(cut -d "/" -f 2 <<< $K8S_APP_REPO)
ENV=$(cut -d "-" -f 3 <<< $DEPLOYMENT_NAME)
COMMIT_SHA_SHORT=$(git rev-parse --short HEAD 2>/dev/null)
DOCKER_IMAGE_PATH="gcr.io/${GCE_PROJECT}/${ENV}/${APP_NAME}"

echo "Building image..."
gcloud docker -- pull $DOCKER_IMAGE_PATH:latest || true
docker build . --build-arg bundle_gems__contribsys__com --cache-from $DOCKER_IMAGE_PATH:latest -t $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT
docker tag $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT $DOCKER_IMAGE_PATH:latest
gcloud docker -- push $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT
gcloud docker -- push $DOCKER_IMAGE_PATH:latest
