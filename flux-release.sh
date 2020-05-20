#!/bin/bash

FLUX_NAMESPACE="flux"
APP_NAME=$(cut -d "/" -f 2 <<< "${K8S_APP_REPO}")
HELM_RELEASE="helmrelease/${DEPLOYMENT_NAME}"
DOCKER_IMAGE_REPO="gcr.io/${GCE_PROJECT}/${APP_NAME}"
VERSION_VALUE=$(git --git-dir=/${TRAVIS_BUILD_DIR}/src/.git describe --always --tags 2>/dev/null)
NOTIFICATION_DATA='{"build_url":"'${TRAVIS_BUILD_WEB_URL}'"}'

docker pull $DOCKER_IMAGE_REPO:$VERSION_VALUE

sleep 120 # flux operator caches registry every minute

if [[ $DEPLOYMENT_NAME =~ ^travis-pro ]]; then
  NS=gce-$PROJECT-pro-services-1
  WORKLOAD=gce-$PROJECT-pro-services-1
else
  NS=gce-$PROJECT-services-1
  WORKLOAD=gce-$PROJECT-services-1
fi

APPS_NS=$(yq r ./apps.yaml ${DEPLOYMENT_NAME}-${PROJECT}.namespace);
if [[ "xx${APPS_NS}" != "xx" ]]; then
  NS=${APPS_NS}
fi

echo fluxctl --k8s-fwd-ns=$FLUX_NAMESPACE release \
          --workload $WORKLOAD:$HELM_RELEASE \
          --namespace $NS \
          --update-image=$DOCKER_IMAGE_REPO:$VERSION_VALUE

fluxctl --k8s-fwd-ns=$FLUX_NAMESPACE release \
          --workload $WORKLOAD:$HELM_RELEASE \
          --namespace $NS \
          --update-image=$DOCKER_IMAGE_REPO:$VERSION_VALUE

if [ "$?" -eq "0" ]; then
  curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/success
  exit 0
else
  curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/failed
  exit 1
fi
