#!/bin/bash

if [ ! -z $DEPLOY_AIDA ];then
  if [ -z $TRAVIS_BUILDARG_AIDA_URL ]; then
    echo "Aida deploy requested, but no TRAVIS_BUILDARG_AIDA_URL provided"
    exit 0
  fi
  body="{
    \"request\": {
    \"message\": \"Update aida library: ${TRAVIS_BUILDARG_AIDA_URL}\",
    \"branch\":\"ga-dpl\",
    \"config\": {
    \"env\":{\"AIDA_URL\":\"${TRAVIS_BUILDARG_AIDA_URL}\",\"AIDA_DEPLOY\":\"true\"}
  }}}"
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token $TRAVIS_TOKEN" \
    -d "$body" \
    https://api.travis-ci.com/repo/travis-ci%2Ftravis-aida/requests
fi


