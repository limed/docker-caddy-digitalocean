FROM caddy:builder AS builder

RUN xcaddy build \
	--with github.com/caddy-dns/digitalocean@master

FROM caddy:2-alpine AS runtime

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
