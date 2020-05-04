#!/bin/bash
set -e
cd "$(dirname "$0")"
if [ $# -eq 0 ] ; then
  echo "Usage: ./build-deploy [buid|deploy] sha1 sha2"
  exit 1
fi

ACTION=$1

IS_COMMON_UPDATED=$(git diff --name-only  "$2" "$3" | grep -e "services/common" -e "shared/deployments" | wc -l)
IS_REDEPLOY=$(git log --format=%B -n 1 $3 | grep  -F '[ redeploy-all ]' | wc -l )

function deployResources(){
  find ../shared/deployments -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read directory; do
    echo $directory
    cd "$directory" ; sls deploy;
  done
}

function buildServices(){
  find ../services -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read directory; do
    make build -C "$directory"
  done
}

function deployServices(){
  find ../services -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read directory; do
    make deploy -C "$directory"
  done
}

# If common packages or services updated, all services re deploys
if [ $IS_COMMON_UPDATED -gt 0 ] ; then
  echo "Common packages updated, redeploying all services"
  if [ "$ACTION" == "build" ]; then
     buildServices
    else
      deployResources
      deployServices
  fi

  exit 0
fi
# If in message there is [ redeploy-all ] phase, re-deploying all services
if [ $IS_REDEPLOY -gt 0 ] ; then
  echo "Re-deploy requested, re-deploying all services..."
  if [ "$ACTION" == "build" ]; then
     buildServices
    else
      deployResources
      deployServices
  fi
  exit 0
fi

#PARTIAL BUILD - checking which files are changed building and deploying those services which are changed.
git diff --name-only  $2 $3 |
grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::' | sort | uniq |
while read -r  line ; do
  if [ -d "../$line" ]; then
    if [ -f "../$line/serverless.yml" ] ; then
      echo "deploying $line ..."
       if [ "$ACTION" == "build" ] ; then make build -C "../$line" ; else  make deploy -C "../$line" ; fi
    fi
  fi
done
