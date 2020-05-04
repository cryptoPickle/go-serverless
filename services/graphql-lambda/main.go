package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/cryptoPickle/go-serverless/services/common/constants"
	"github.com/cryptoPickle/go-serverless/services/common/schemas"
)

var (
	ErrQueryNameNotProvided = errors.New("no query was provided in the HTTP body")
)

type Response events.APIGatewayProxyResponse

func Handler(ctx context.Context, request *events.APIGatewayProxyRequest) (Response, error) {
	log.Printf("Lambda request %s\n", request.RequestContext.RequestID)

	if len(request.Body) < 1 {
		return Response{}, ErrQueryNameNotProvided
	}

	var params struct {
		Query         string                 `json:"query"`
		OperationName string                 `json:"operationName"`
		Variables     map[string]interface{} `json:"variables"`
	}

	if err := json.Unmarshal([]byte(request.Body), &params); err != nil {
		log.Print("Could not decode body", err)
	}

	response := schemas.MainSchema.Exec(ctx, params.Query, params.OperationName, params.Variables)

	responseJSON, err := json.Marshal(response)

	if err != nil {
		log.Println("Could not decode body")
	}

	return Response{
		Body:       string(responseJSON),
		StatusCode: constants.StatusCodes["Ok"],
	}, nil
}

func main() {
	lambda.Start(Handler)
}
