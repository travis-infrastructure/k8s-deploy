#!/bin/bash

set -o errexit
set -xv

#
# This script checks if image already exist in registry, if not it will build and tag image
#

APP_NAME=$(cut -d "/" -f 2 <<< $K8S_APP_REPO)
COMMIT_SHA_SHORT=$(git describe --always --tags 2>/dev/null)
DOCKER_IMAGE_PATH="gcr.io/${GCE_PROJECT}/${APP_NAME}"
DOCKER_IMAGE_TAG=$(gcloud container images list-tags ${DOCKER_IMAGE_PATH} --filter="tags=${COMMIT_SHA_SHORT}" --format=json)

if [[ "${DOCKER_IMAGE_TAG}" == "[]" ]]; then
  echo "Tag doesn't exist in gcr.io. Building image..."
  gcloud docker -- pull $DOCKER_IMAGE_PATH:latest || true
  docker build . --build-arg bundle_gems__contribsys__com --cache-from $DOCKER_IMAGE_PATH:latest -t $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT
  docker tag $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT $DOCKER_IMAGE_PATH:latest
  gcloud docker -- push $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT
  gcloud docker -- push $DOCKER_IMAGE_PATH:latest
  echo "Wait a little bit for the indexing"
  sleep 120
else
  echo "Image already exist in gcr.io"
  exit 0
fi
