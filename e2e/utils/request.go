package utils

import "github.com/cryptoPickle/go-serverless/services/common/req"

// SET BASE URL LATER ON
func Request() *req.Client {
	return req.NewRequestClient("https://xsjbgc3pjb.execute-api.eu-west-1.amazonaws.com")
}
