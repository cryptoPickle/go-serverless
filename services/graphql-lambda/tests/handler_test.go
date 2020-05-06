package handler_test

import (
	"context"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/cryptoPickle/go-serverless/services/graphql-lambda/handler"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("graphql-lambda service test", func() {
	It("Should return response correctly", func() {
		test := struct {
			request *events.APIGatewayProxyRequest
			expect  string
		}{
			request: &events.APIGatewayProxyRequest{
				Body: `{"query":"query test {\n  person(id:\"1000\") {\n    id\n    firstName\n  }\n}\n","variables":null,"operationName":"test"}`,
			},
			expect: "{\"data\":{\"person\":{\"id\":\"1000\",\"firstName\":\"Halil\"}}}",
		}
		response, err := handler.Handler(context.TODO(), test.request)
		Expect(err).To(BeNil())
		Expect(response.Body).To(Equal(test.expect))

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "graphql-lambda Service Test Suite")
}
