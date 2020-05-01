.PHONY: build clean deploy

build-hello:
	env GOOS=linux go build -ldflags="-s -w" -o hello/bin/hello hello/main.go

build-graphql-lambda:
	env GOOS=linux go build -ldflags="-s -w" -o graphql-lambda/bin/graphql graphql-lambda/main.go

build-world:
	env GOOS=linux go build -ldflags="-s -w" -o world/bin/world world/main.go

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose


gomodgen:
	chmod u+x gomod.sh
	./gomod.sh