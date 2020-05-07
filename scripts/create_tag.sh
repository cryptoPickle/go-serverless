#!/bin/bash
echo "::set-output name=realaseName::$(date +"%m-%d-%Y")"
echo "::set-output name=relaseBody::$(git --no-pager log --format=%B  $1 $2)"