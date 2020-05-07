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
