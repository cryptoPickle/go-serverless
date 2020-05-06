package handler_test

import (
	"context"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/cryptoPickle/go-serverless/services/hello/handler"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Hello service test", func() {
	It("Should return response correctly", func() {
		test := struct {
			expect string
		}{
			expect: "{\"message\":\"Go Serverless v1.0! Your function executed successfuls!\"}",
		}

		request := events.APIGatewayProxyRequest{}
		response, err := handler.Handler(context.TODO(), &request)
		Expect(err).To(BeNil())
		Expect(response.Body).To(Equal(test.expect))

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "hello Service Test Suite")
}
