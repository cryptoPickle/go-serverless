.PHONY: build clean deploy gomodgen

build: gomodgen
	make build-world -C ../

clean:
	rm -rf ./bin ./vendor Gopkg.lock

deploy: clean build
	sls deploy --verbose
