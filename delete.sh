find . -type d -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read line; do
  cd $line ; sls remove
done;