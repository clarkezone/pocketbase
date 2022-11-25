#Stage 1 build and test
#docker.io prefix required by podman
# use podman build . --build-arg BUILD_VERSION="jikjikjik" --build-arg BUILD_HASH="0001100"
FROM docker.io/golang:alpine as builder
ARG BUILD_VERSION
RUN mkdir /build
WORKDIR /build
# RUN apk --no-cache add gcc build-base git
# RUN go install github.com/goreleaser/goreleaser@latest
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
#RUN go build -ldflags="-s -w -X github.com/pocketbase/pocketbase.Version=$BUILD_VERSION" -o pocketbase
RUN CGO_ENABLED=0 go build -ldflags="-s -w -X github.com/pocketbase/pocketbase.Version=$BUILD_VERSION" -o pocketbase examples/base/main.go 
#Stage 2 build final image
FROM docker.io/alpine:3.14
RUN apk update
RUN apk --no-cache add ca-certificates
COPY --from=builder /build/pocketbase .
CMD ./pocketbase serve --http 0.0.0.0:8080 --dir /data