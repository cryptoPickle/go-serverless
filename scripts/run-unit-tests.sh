#!/bin/bash

set -e
cd "$(dirname "$0")"

find ../services -name "*_test.go" -type f | while read -r service; do
  go test -v "$service"
done