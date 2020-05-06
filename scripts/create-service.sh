#!/bin/bash

if [ $# -eq 0 ] ; then
  echo 'Usage: create-service serviceName'
  exit 1
fi

SERVICE_NAME=$1
SERVICE_PATH=./services/$SERVICE_NAME

mkdir -p $SERVICE_PATH
mkdir -p $SERVICE_PATH/handler
mkdir -p $SERVICE_PATH/tests

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
  profile: \${self:custom.profiles.\${self:provider.stage}}
  stage: dev
  tracing:
    apiGateway: true
    lambda: true
  apiGateway:
    \${file(../../shared/resources/agw/agwId.yml):apiGateway}
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
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/cryptoPickle/go-serverless/services/hello/handler"
)

func main() {
	lambda.Start(handler.Handler)
}

EOF_GO

cat > $SERVICE_PATH/handler/handler.go <<EOF_GO
package handler

import (
	"bytes"
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"

	"github.com/cryptoPickle/go-serverless/services/common/constants"
)

type Response events.APIGatewayProxyResponse

func Handler(ctx context.Context, request *events.APIGatewayProxyRequest) (Response, error) {
	var buf bytes.Buffer

	body, err := json.Marshal(map[string]interface{}{
		"message": "Go Serverless v1.0! Your function executed successful!",
	})
	if err != nil {
		return Response{StatusCode: constants.StatusCodes["NotFound"]}, err
	}
	json.HTMLEscape(&buf, body)

	resp := Response{
		StatusCode:      constants.StatusCodes["Ok"],
		IsBase64Encoded: false,
		Body:            buf.String(),
		Headers: map[string]string{
			"Content-Type":           "application/json",
			"X-MyCompany-Func-Reply": "hello-handler",
		},
	}

	return resp, nil
}
EOF_GO

cat > $SERVICE_PATH/tests/handler_test.go <<EOF_GO
package handler_test

import (
	"context"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/cryptoPickle/go-serverless/services/${SERVICE_NAME}/handler"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("${SERVICE_NAME} service test", func() {
	It("Should return response correctly", func() {
		test := struct {
			expect string
		}{
			expect: "{\"message\":\"Go Serverless v1.0! Your function executed successful!\"}",
		}

		request := events.APIGatewayProxyRequest{}
		response, err := handler.Handler(context.TODO(), &request)
		Expect(err).To(BeNil())
		Expect(response.Body).To(Equal(test.expect))

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "${SERVICE_NAME} Service Test Suite")
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
	sudo sls deploy --verbose
EOF_MAKEFILE