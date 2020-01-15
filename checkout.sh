#!/bin/bash

# 
# K8S_APP_REPO - github repository path, example: travis-ci/app-name
# K8S_APP_REPO_COMMIT (optional) - commit SHA or branch name, if empty it defaults to HEAD of master branch
#

if [[ -z $K8S_APP_REPO ]]; then
  echo "Environment variable K8S_APP_REPO not set"
  exit 1
fi

git clone git@github.com:$K8S_APP_REPO $TRAVIS_BUILD_DIR/src

if [[ $K8S_APP_REPO_COMMIT ]]; then
  cd $TRAVIS_BUILD_DIR/src
  git checkout $K8S_APP_REPO_COMMIT 
fi
