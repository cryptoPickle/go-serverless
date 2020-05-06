#!/bin/bash
set -e
cd "$(dirname "$0")"
if [ $# -eq 0 ] ; then
  echo "Usage: ./build-deploy [buid|deploy] sha1 sha2"
  exit 1
fi

bold=$(tput bold)
normal=$(tput sgr0)
color=$(tput setaf 2)
echo "${bold}$(tput setaf 2) this is bold$(tput setaf 0) but this isn't ${normal}"
ACTION=$1

IS_COMMON_UPDATED=$(git diff --name-only  "$2" "$3" | grep -e "services/common" -e "shared/deployments" | wc -l)
IS_REDEPLOY=$(git log --format=%B -n 1 $3 | grep  -F '[ redeploy-all ]' | wc -l )

function deployResources(){
  find ../shared/deployments -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read directory; do
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
  echo "${bold}$(tput setaf 5) Common packages updated, redeploying all services ${normal}"
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
  echo "${bold}$(tput setaf 5) "Re-deploy requested, re-deploying all services..." ${normal}"
  if [ "$ACTION" == "build" ]; then
     buildServices
    else
      deployResources
      deployServices
  fi
  exit 0
fi

#PARTIAL BUILD - checking which files are changed building and deploying those services which are changed.

RESOURCES=()
DIFF=$( git diff --name-only  $2 $3 | grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::'  | grep "services" )


while read -r  line ; do
  RESOURCES+=("$(dirname $line)")
done <<< "$( echo -e "$DIFF")"


for line in $(echo "${RESOURCES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
do
  if [ -d "../$line" ]; then
    if [ -f "../$line/serverless.yml" ] ; then
       if [ "$ACTION" == "build" ] ; then
         echo "${bold}$(tput setaf 5) Building... $(tput setaf 3) $line ${normal}"
         make build -C "../$line" ;
         else
           echo "${bold}$(tput setaf 9) Deploying... $(tput setaf 11) $line ${normal}"
           make deploy -C "../$line" ;
      fi
    fi
  fi
done

#5 3