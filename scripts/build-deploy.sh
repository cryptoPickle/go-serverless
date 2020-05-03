echo "STARTING..."
if [ $# -eq 0 ] ; then
  echo "Usage: ./build-deploy [buid|deploy] sha1 sha2"
  exit 1
fi

ACTION=$1

function buildeploy() {
  for d in $(find . -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print ); do
    if [ "$ACTION" == "build" ] ; then make build -C $d ; else  make deploy -C $d ; fi
  done
}

IS_COMMON_UPDATED=$(git diff --name-only  $2..$3 | grep "services/common" | wc -l)
COMMIT_MESSAGE=$(git --no-pager log --format=%B -n 1 $GITHUB_SHA )
echo "MESSAGE $COMMIT_MESSAGE"
if [ $IS_COMMON_UPDATED -gt 0 ] ; then
  echo "Common packages updated, redeploying all services"
  buildeploy
fi

if [ "$COMMIT_MESSAGE" == "[ redeploy-all ]" ] ; then
  echo "Re-deploy requested, re-deploying all services..."
  buildeploy
fi

git git diff --name-only  $2..$3 |
grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::' | sort | uniq |
while read line ; do
  echo "$line"
  if [ -d "$line" ]; then
    echo $line
    if [ -f "$line/serverless.yml" ] ; then
      echo "deploying $line ..."
       if [ "$ACTION" == "build" ] ; then make build -C $line ; else  make deploy -C $line ; fi
    fi
  fi
done
