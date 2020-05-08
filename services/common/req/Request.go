package req

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/url"
	"time"
)

type Client struct {
	baseUrl *url.URL
	client  *http.Client
}

type Response struct {
	Body       *string
	Headers    http.Header
	StatusCode int
	Response   *http.Response
}

func NewRequestClient(baseurl string) *Client {
	u1, err := url.Parse(baseurl)
	if err != nil {
		log.Fatal(err)
	}

	return &Client{
		baseUrl: u1,
		client: &http.Client{
			Transport: &http.Transport{
				Dial: (&net.Dialer{
					Timeout: 5 * time.Second,
				}).Dial,
			},
			Timeout: time.Second * 10,
		},
	}
}

func (c *Client) Get(url string, headers map[string]string) (*Response, error) {
	parseUrl := c.parseUrl(url)
	req := createRequest("GET", parseUrl, headers, nil)
	res, err := c.makeRequest(req)
	if err != nil {
		return nil, err
	}
	response := string(res.responseByte)

	return &Response{
		Body:       &response,
		Headers:    res.response.Header,
		StatusCode: res.response.StatusCode,
		Response:   res.response,
	}, nil
}

func (c *Client) Post(url string, body interface{}, headers map[string]string) (*Response, error) {
	parseUrl := c.parseUrl(url)
	b, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}
	req := createRequest("POST", parseUrl, headers, b)
	res, err := c.makeRequest(req)

	if err != nil {
		return nil, err
	}
	response := string(res.responseByte)

	return &Response{
		Body:       &response,
		Headers:    res.response.Header,
		StatusCode: res.response.StatusCode,
		Response:   res.response,
	}, nil

}

func (c *Client) parseUrl(urlPath string) *url.URL {
	path, err := url.Parse(urlPath)

	if err != nil {
		log.Fatal(err)
	}
	return c.baseUrl.ResolveReference(path)
}

type makeRequest struct {
	response     *http.Response
	responseByte []byte
}

func (c *Client) makeRequest(req *http.Request) (*makeRequest, error) {
	res, err := c.client.Do(req)

	if err != nil {
		return nil, err
	}

	b, err := ioutil.ReadAll(res.Body)
	defer res.Body.Close()

	if err != nil {
		return nil, err
	}

	return &makeRequest{
		response:     res,
		responseByte: b,
	}, nil
}

func createRequest(method string, url *url.URL, headers map[string]string, body []byte) *http.Request {
	b := bytes.NewBuffer(body)
	req, err := http.NewRequest(method, url.String(), b)

	if err != nil {
		log.Fatal(err)
	}

	for key, value := range headers {
		req.Header.Set(key, value)
	}

	return req
}
