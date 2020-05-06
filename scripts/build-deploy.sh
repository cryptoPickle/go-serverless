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
  printf "\e[1;33m Common packages updated, redeploying all services \e[1;0m\n"
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
  printf "\e[1;33m Re-deploy requested, re-deploying all services...\e[1;0m\n"
  echo "${bold}$(tput setaf 5)  ${normal}"
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
CHANGE_COUNT=$( git --no-pager diff --name-only  $2 $3 | grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::'  | grep "services" | wc -l)

if [ $CHANGE_COUNT -eq 0 ]; then
  echo "::set-output name=deploy::false"
  printf "\e[1;31m No change on services found exiting... \e[1;0m"
  exit 0
fi
echo "::set-output name=deploy::true"
DIFF=$( git --no-pager diff --name-only  $2 $3 | grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::'  | grep "services" )


echo "here"
while read -r  line ; do
  RESOURCES+=("$(dirname $line)")
done <<< "$( echo -e "$DIFF")"


for line in $(echo "${RESOURCES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
do
  if [ -d "../$line" ]; then
    if [ -f "../$line/serverless.yml" ] ; then
       if [ "$ACTION" == "build" ] ; then
         printf "\e[31m Building... \e[0m"
         printf "\e[1;33m $line \e[1;0m\n"
         make build -C "../$line" ;
         else
          printf "\e[31m Deploying... \e[0m"
          printf "\e[1;33m $line \e[1;0m\n"
          make deploy -C "../$line" ;
      fi
    fi
  fi
done
