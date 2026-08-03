FROM golang:alpine AS builder

RUN apk add --no-cache git ca-certificates

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

RUN CGO_ENABLED=0 xcaddy build \
	--output /usr/bin/caddy \
	--with github.com/caddy-dns/digitalocean@master

FROM scratch AS runtime

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

EXPOSE 80 443 443/udp 2019

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
