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

DOCKER_ARGS=''
prefix='TRAVIS_BUILDARG_'
for varname in $(env | grep "^${prefix}"); do
  varname=${varname/#$prefix}
  DOCKER_ARGS="${DOCKER_ARGS} --build-arg $varname "
done

secret_prefix='TRAVIS_BUILDSECRET_'
for varname in $(env | grep "^${secret_prefix}" | cut -d'=' -f 1); do
  envname=$varname
  varname=${varname/#$secret_prefix}
  DOCKER_ARGS="${DOCKER_ARGS} --secret id=$varname,env=$envname "
done

echo "Adding custom build arguments: ${DOCKER_ARGS}"

echo "Building image..."
gcloud docker -- pull $DOCKER_IMAGE_PATH:latest || true
if [[ "${APP_NAME}" == "travis-web" ]]; then
  docker build . --secret id=GITHUB_PERSONAL_TOKEN,env=GITHUB_PERSONAL_TOKEN --build-arg bundle_gems__contribsys__com --cache-from $DOCKER_IMAGE_PATH:latest -t $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT $DOCKER_ARGS
else
  docker build . --build-arg bundle_gems__contribsys__com --cache-from $DOCKER_IMAGE_PATH:latest -t $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT $DOCKER_ARGS
fi
docker tag $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT $DOCKER_IMAGE_PATH:latest
gcloud docker -- push $DOCKER_IMAGE_PATH:build-${TRAVIS_BUILD_NUMBER}-$COMMIT_SHA_SHORT
gcloud docker -- push $DOCKER_IMAGE_PATH:latest
