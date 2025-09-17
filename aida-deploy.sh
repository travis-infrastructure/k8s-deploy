#!/bin/bash

echo "=== AIDA Deploy Script Started ==="
echo "DEPLOY_AIDA: '$DEPLOY_AIDA'"
echo "TRAVIS_BUILDARG_STAGING_AIDA_URL: '$TRAVIS_BUILDARG_STAGING_AIDA_URL'"
echo "TRAVIS_TOKEN: '$(if [ -z "$TRAVIS_TOKEN" ]; then echo "NOT SET"; else echo "SET (length: ${#TRAVIS_TOKEN})"; fi)'"

if [ ! -z $DEPLOY_AIDA ];then
  echo "DEPLOY_AIDA is set, proceeding with deployment..."
  if [ -z $TRAVIS_BUILDARG_STAGING_AIDA_URL ]; then
    echo "ERROR: Aida deploy requested, but no TRAVIS_BUILDARG_STAGING_AIDA_URL provided"
    exit 0
  fi
  echo "Building request body for Travis API..."
  body="{
    \"request\": {
    \"message\": \"Update aida library: ${TRAVIS_BUILDARG_STAGING_AIDA_URL}\",
    \"branch\":\"ga-dpl\",
    \"config\": {
    \"env\":{\"AIDA_URL\":\"${TRAVIS_BUILDARG_STAGING_AIDA_URL}\",\"AIDA_DEPLOY\":\"true\"}
  }}}"
  echo "Request body: $body"
  echo "Making API call to Travis CI..."

  response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token $TRAVIS_TOKEN" \
    -d "$body" \
    https://api.travis-ci.com/repo/travis-ci%2Ftravis-aida/requests)

  echo "API Response: $response"
  echo "AIDA deployment request completed successfully"
else
  echo "DEPLOY_AIDA is not set or empty, skipping AIDA deployment"
fi

echo "=== AIDA Deploy Script Finished ==="


