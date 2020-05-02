.PHONY: build clean deploy

build: clean
	export GO111MODULE=on
	env GOOS=linux go build  -ldflags '-d -s -w' -a  -o bin/graphql main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy:
	sls deploy --verbose
