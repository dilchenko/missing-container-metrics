# Multi-arch build: cross-compiles on the build platform for the target
# platform (linux/amd64, linux/arm64) instead of emulating the target.
# Same toolchain and flags as the original upstream Dockerfile.
FROM --platform=$BUILDPLATFORM golang:1.16-alpine3.12 as build

RUN mkdir /missing-container-metrics
WORKDIR /missing-container-metrics
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=master
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-X main.Version=$VERSION" -o missing-container-metrics .

FROM scratch
COPY --from=build /missing-container-metrics/missing-container-metrics /missing-container-metrics
EXPOSE 3001
ENTRYPOINT ["/missing-container-metrics"]
