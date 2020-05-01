FROM golang:1.11.4-stretch

LABEL "com.github.actions.name"="Build Binaries"
LABEL "com.github.actions.description"="Run make to build the Golang binary."

RUN ls

RUN echo $GOPATH

RUN echo "##[set-env name=GOPATH;]$(dirname $GITHUB_WORKSPACE)" ;echo "##[add-path]$(dirname $GITHUB_WORKSPACE)/bin"
RUN set -eux; \
	export GOROOT="$(go env GOROOT)";

CMD make build