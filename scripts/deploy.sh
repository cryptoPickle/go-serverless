function deploy_all() {
    for d in $(find ../services -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print ); do
      make deploy -C $d
    done
}


IS_COMMON_UPDATED=$(git diff-tree --no-commit-id --name-only -r 12d5d23 | grep "services/common" | wc -l)
COMMIT_MESSAGE=$(git --no-pager log --format=%B -n 1 5760b55)

if [ $IS_COMMON_UPDATED -gt 0 ] ; then
  echo "Common packages updated, redeploying all services"
  deploy_all
fi

if [ $COMMIT_MESSAGE == "[ redeploy-all ]" ] ; then
  echo "Re-deploy requested, re-deploying all services..."
  echo "REBUILD"
fi

git diff-tree --no-commit-id --name-only -r $GITHUB_SHA |
grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::' | sort | uniq |
while read line ; do
  if [ -d "../$line" ]; then
    if [ -f "../$line/serverless.yml" ] ; then
      echo "deploying $line ..."
      make deploy  -C "../$line"
    fi
  fi
done


