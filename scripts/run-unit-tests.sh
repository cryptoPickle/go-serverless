#!/bin/bash

set -e
cd "$(dirname "$0")"

EVENT_NAME=$1


function runPartialTest() {
  while read -r  line ; do
    RESOURCES+=("$(dirname $line)")
  done <<< "$( echo -e "$DIFF")"

  for service in $(echo "${RESOURCES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
  do
    find "../$service" -name "*_test.go" -type f | while read -r testFile; do
      go test -v "$testFile"
    done
  done
}


if [ "$EVENT_NAME" == 'pull_request' ]; then
      RESOURCES=()
      DIFF=$( git --no-pager diff --name-only FETCH_HEAD $(git merge-base FETCH_HEAD master))
      runPartialTest
  else
    find ../services -name "*_test.go" -type f | while read -r service; do
      go test -v "$service"
    done
fi

