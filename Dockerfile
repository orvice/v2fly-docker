FROM golang:1.20 AS builder
RUN apk update && apk add --no-cache git bash wget
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
	bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz

FROM alpine:3.16

LABEL maintainer "orvice <orvice@orx.me>"
COPY --from=builder /tmp/v2ray.tgz /tmp
RUN apk update && apk add ca-certificates && \
	mkdir -p /usr/bin/v2ray && \
	tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray

#ENTRYPOINT ["/usr/bin/v2ray/v2ray"]
ENV PATH /usr/bin/v2ray:$PATH
CMD ["v2ray", "-config=/etc/v2ray/config.json"]