#!/bin/bash

#
# This script checks if image already exist in registry, if not it will build and tag image
# 

APP_NAME=$(cut -d "/" -f 2 <<< $K8S_APP_REPO)
COMMIT_SHA_SHORT=$(git describe --always --tags 2>/dev/null)
DOCKER_IMAGE_PATH="gcr.io/travis-ci-${PROJECT}-services-1/${APP_NAME}"
DOCKER_IMAGE_TAG=$(gcloud container images list-tags ${DOCKER_IMAGE_PATH} --filter="tags=${COMMIT_SHA_SHORT}" --format=json)

if [[ "${DOCKER_IMAGE_TAG}" == "[]" ]]; then
  echo "Tag doesn't exist in gcr.io. Building image..."
  docker build . -t $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT
  docker tag $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT $DOCKER_IMAGE_PATH:latest
  gcloud docker -- push $DOCKER_IMAGE_PATH:$COMMIT_SHA_SHORT
  gcloud docker -- push $DOCKER_IMAGE_PATH:latest

else
  echo "Image already exist in gcr.io"
  exit 0
fi
