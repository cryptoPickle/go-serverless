find . -type d -maxdepth 2 -exec sh -c '[ -f "$0"/serverless.yml ]' '{}' \; -print | while read line; do
  echo $line
  cd $line ; sls remove
done;