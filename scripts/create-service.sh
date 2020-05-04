#!/bin/bash

if [ $# -eq 0 ] ; then
  echo 'Usage: create-service serviceName'
fi

SERVICE_NAME=$1
SERVICE_PATH=./services/$SERVICE_NAME

mkdir -p $SERVICE_PATH

cat > $SERVICE_PATH/serverless.yml <<EOF_YML
service: ${SERVICE_NAME}
frameworkVersion: '>=1.28.0 <2.0.0'

.commonconfig: &commonconfig
  \${file(../../shared/common/serverless.common.yml):commonResources}

custom: \${file(../../shared/common/serverless.common.yml):custom}

package:
  individually: true
  exclude:
    - ./**
  include:
    - ./bin/**

provider:
  name: aws
  runtime: go1.x
  region: \${self:custom.region}
  stage: dev
  tracing:
    apiGateway: true
    lambda: true
  environment:
    stage: \${self:custom.stage}
    resourcesStage: \${self:custom.resourcesStage}
  iamRoleStatements:
    - \${file(../../shared/common/serverless.common.yml):lambdaPolicyXray}

## TODO: please change config depends on your needs
functions:
  \${SERVICE_NAME}:
    handler: bin/${SERVICE_NAME}
    events:
      - http:
          path: ${SERVICE_NAME}
          method: post


resources:
  - *commonconfig
  #  Create Base API, rest of the services depends on this service, deploy first
  - \${file(../../shared/resources/agw/base_api.yml)}
EOF_YML

cat > $SERVICE_PATH/main.go <<EOF_GO
package main

import (
	"bytes"
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// https://serverless.com/framework/docs/providers/aws/events/apigateway/#lambda-proxy-integration
type Response events.APIGatewayProxyResponse

// Handler is our lambda handler invoked by the "lambda.Start" function call
func Handler(ctx context.Context) (Response, error) {
	var buf bytes.Buffer

	body, err := json.Marshal(map[string]interface{}{
		"message": "Go Serverless v1.0! Your ${SERVICE_NAME} function executed successfully!",
	})
	if err != nil {
		return Response{StatusCode: 404}, err
	}
	json.HTMLEscape(&buf, body)

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Body:            buf.String(),
		Headers: map[string]string{
			"Content-Type":           "application/json",
			"X-MyCompany-Func-Reply": "hello-handler",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(Handler)
}
EOF_GO

cat > $SERVICE_PATH/Makefile <<EOF_MAKEFILE
  .PHONY: build clean deploy

build: clean
	export GO111MODULE=on
	env GOOS=linux go build -ldflags="-s -w" -o bin/${SERVICE_NAME} main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy:
	sls deploy --verbose
EOF_MAKEFILE