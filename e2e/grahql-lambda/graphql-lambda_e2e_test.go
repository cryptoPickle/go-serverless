package e2etest

import (
	"encoding/json"
	"testing"

	"github.com/cryptoPickle/go-serverless/e2e/utils"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("graphql-lambda service e2e test", func() {
	It("Should return response correctly", func() {
		test := struct {
			expect string
		}{
			expect: "{\"data\":{\"person\":{\"id\":\"1000\",\"firstName\":\"Halil\"}}}",
		}

		c := utils.Request()
		res, err := c.Post(
			"/dev/graphql-lambda",
			json.RawMessage(
				`{"query":"query test {\n  person(id:\"1000\") {\n    id\n firstName\n  }\n}\n","variables":null,"operationName":"test"}`,
			),
			nil)
		Expect(err).To(BeNil())
		Expect(test.expect).To(Equal(*res.Body))

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "graphql-lambda Service e2e tests")
}
