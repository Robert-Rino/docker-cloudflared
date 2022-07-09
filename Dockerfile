# Build container
ARG GOVERSION=1.18.3
ARG ALPINEVERSION=3.16
ARG BUILDPLATFORM=linux/amd64

FROM --platform=${BUILDPLATFORM} \
    golang:$GOVERSION-alpine${ALPINEVERSION} AS build

WORKDIR /src
RUN apk --no-cache add git build-base

ENV GO111MODULE=on \
    CGO_ENABLED=0

ARG VERSION=2022.6.3
RUN git clone https://github.com/cloudflare/cloudflared --depth=1 --branch ${VERSION} .
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make cloudflared

# Runtime container
FROM alpine:${ALPINEVERSION}

WORKDIR /

ENV TUNNEL_ORIGIN_CERT=/etc/cloudflared/cert.pem

COPY --from=build /src/cloudflared /bin
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["cloudflared"]
CMD ["version"]
