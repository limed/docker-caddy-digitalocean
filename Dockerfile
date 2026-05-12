FROM golang:alpine AS builder

RUN apk add --no-cache git

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

RUN xcaddy build \
	--output /usr/bin/caddy \
	--with github.com/caddy-dns/digitalocean@master

FROM caddy:2-alpine AS runtime

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
