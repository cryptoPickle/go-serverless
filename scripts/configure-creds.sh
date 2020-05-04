#!/bin/bash
set -e

USAGE="./credentials.sh accesskey secretkey"

if [ "$#" -ne 2 ] ; then
    echo "Illegal number of parameters"
    echo "Usage: $USAGE"
    exit 1
fi

ENV=$1

CONFIG="[default]\nregion=eu-west-1\noutput=json"

KEY_ID="AWS_ACCESS_KEY_ID"
ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

CREDENTIALS="[default]\naws_access_key_id = $1\naws_secret_access_key = $2"

mkdir -p ~/.aws
echo -e ${CONFIG} > ~/.aws/config
echo -e ${CREDENTIALS} > ~/.aws/credentials