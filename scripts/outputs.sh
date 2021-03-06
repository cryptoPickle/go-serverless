#!/bin/bash
CHANGE_COUNT=$( git --no-pager diff --name-only  $1 $2 | grep  -e ".*\.go$" -e ".*\.yml$" | sed 's:[^/]*$::'  | grep "services" | wc -l)

echo "::set-output name=realaseName::$(date +"%m-%d-%Y")-$1'"

if [ $CHANGE_COUNT -eq 0 ]; then
  echo "::set-output name=skip::true"
  printf "\e[1;31m No change on services found skipping... \e[1;0m"
  exit 0
fi

echo "::set-output name=skip::false"