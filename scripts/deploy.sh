git diff-tree --no-commit-id --name-only -r $GITHUB_SHA |
grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::' | sort | uniq |
while read line ; do
  if [ -d "../$line" ]; then
    if [ -f "../$line/serverless.yml" ] ; then
      echo $line
      make deploy  -C "../$line"
    fi
  fi
done

#git diff-tree --no-commit-id --name-only -r $GITHUB_SHA | grep