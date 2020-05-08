package handler_test

import (
	"fmt"
	"testing"

	"github.com/cryptoPickle/go-serverless/services/common/utils"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Hello service test", func() {
	It("Should return response correctly", func() {
		d := utils.NewDispatcher()
		callback := func(e utils.Event) (interface{}, error) {
			return e.Value(), nil
		}

		d.Register("test", callback)
		d.Register("test", callback)
		values, err := d.Dispatch("test", "hello")
		fmt.Println(values)
		Expect(err).To(BeNil())

	})
})

func TestSo(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "hello Service Test Suite")
}
