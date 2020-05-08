package e2etest

import (
	"testing"

	"github.com/cryptoPickle/go-serverless/e2e/utils"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Hello service e2e test", func() {
	It("Should return response correctly", func() {
		test := struct {
			expect string
		}{
			expect: "{\"message\":\"Go Serverless v1.0! Your function executed successful!\"}",
		}

		c := utils.Request()
		res, err := c.Get("/dev/hello", nil)

		Expect(err).To(BeNil())
		Expect(test.expect).To(Equal(*res.Body))

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "hello Service e2e Test Suite")
}
