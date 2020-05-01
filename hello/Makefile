.PHONY: build clean deploy

build:
	make build-hello -C ../

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose

