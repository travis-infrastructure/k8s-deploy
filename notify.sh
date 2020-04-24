if [ "$@" == 0 ]; then
    curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/success;
    exit 0;
else
    curl -k -H "Content-Type: application/json" -X POST -d $NOTIFICATION_DATA https://fluxbot-staging.travis-ci.org/hubot/$PROJECT/$K8S_APP_REPO/$K8S_APP_REPO_COMMIT/failed;
    exit 1;
fi