set -e
cd "$(dirname "$0")"
if [ $# -eq 0 ] ; then
  echo "Usage: ./build-deploy [buid|deploy] sha1 sha2"
  exit 1
fi

ACTION=$1


function buildeploy() {
  echo "here"
  for d in $(find ../shared/deployments -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print ); do
    if [ "$ACTION" == "build" ] ; then echo "..." ; else cd "$d" ; sls deploy; fi
  done
  cd - > /dev/null
  for d in $(find ../services -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print ); do
    if [ "$ACTION" == "build" ] ; then make build -C "$d" ; else  make deploy -C "$d" ; fi
  done
}



echo $IS_COMMON_UPDATED
echo $COMMIT_MESSAGE
if [[ $IS_COMMON_UPDATED -gt 0 ]] ; then
  echo "Common packages updated, redeploying all services"
  buildeploy
  exit 0
fi

if [[ $COMMIT_MESSAGE -gt 0 ]] ; then
  echo "Re-deploy requested, re-deploying all services..."
  buildeploy
  exit 0
fi


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
