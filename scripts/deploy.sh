#git diff-tree --no-commit-id --name-only -r $GITHUB_SHA |
#grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::' | sort | uniq |
#while read line ; do
#  if [ -d "../$line" ]; then
#    if [ -f "../$line/serverless.yml" ] ; then
#      echo $line
#      make deploy  -C "../$line"
#    fi
#  fi
#done


IS_COMMON_UPDATED=$(git diff-tree --no-commit-id --name-only -r 12d5d23 | grep "services/common" | wc -l)

if [ $IS_COMMON_UPDATED -gt 0 ] ; then
  echo "TRUE"
fi