#!/bin/bash

if hash goimports 2>/dev/null; then
  find . -name "*.go" -type f | while read -r document; do
    echo "Formatting $document ..."
    goimports -e -w -local github.com/cryptopickle/go-serverless "$document"
  done
else
  echo "Instaling goimports"
  go get golang.org/x/tools/cmd/goimports
  find . -name "*.go" -type f | while read -r document; do
    echo "Formatting $document ..."
    goimports -e -w -local github.com/cryptopickle/go-serverless "$document"
  done
fi

echo "Documents formatted."