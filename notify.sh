#!/bin/bash
NOTIFICATION_DATA='{"build_url":"'${TRAVIS_BUILD_WEB_URL}'"}'

if [[ $1 = "success" ]]; then
  echo success
  curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/success
  exit 0
else
  echo failed
  curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/failed
  exit 1
fi