#!/bin/bash

echo "::set-output name=realaseName::Relase_$(date +"%m-%d-%Y")_Relase"
echo "::set-output name=relaseBody::$(git log --format=%B  $1 $2)"