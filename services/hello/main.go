package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/cryptoPickle/go-serverless/services/hello/handler"
)

func main() {
	lambda.Start(handler.Handler)
}
