.PHONY: build clean deploy

build: clean
	export GO111MODULE=on
	env GOOS=linux go build -ldflags="-s -w" -o bin/graphql main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy:
	sls deploy --verbose
