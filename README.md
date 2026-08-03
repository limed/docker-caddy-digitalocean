# docker-caddy-digitalocean

A [Caddy](https://caddyserver.com/) build with the [`caddy-dns/digitalocean`](https://github.com/caddy-dns/digitalocean)
plugin baked in, so Caddy can solve ACME `dns-01` challenges (and issue wildcard certs) using DigitalOcean DNS.

Built with [xcaddy](https://github.com/caddyserver/xcaddy) on top of a minimal `scratch` runtime image (no shell,
no package manager — just the static Caddy binary and CA certs). Published multi-arch (`linux/amd64`, `linux/arm64`)
to GHCR, with an SBOM and Grype vulnerability scan attached to every build.

This is built for my own use case only — use at your own risk.

## Image

```
ghcr.io/limed/caddy-digitalocean:latest
ghcr.io/limed/caddy-digitalocean:<short-sha>
```

## Usage

Write a `Caddyfile` that uses the `digitalocean` DNS provider for the ACME challenge:

```caddyfile
example.com {
	tls {
		dns digitalocean {env.DO_AUTH_TOKEN}
	}

	respond "hello from caddy"
}
```

Run it, mounting the `Caddyfile` and passing your DigitalOcean API token:

```sh
docker run -d \
	--name caddy \
	-p 80:80 -p 443:443 -p 443:443/udp \
	-e DO_AUTH_TOKEN=your_digitalocean_api_token \
	-v ./Caddyfile:/etc/caddy/Caddyfile \
	-v caddy_data:/data \
	-v caddy_config:/config \
	ghcr.io/limed/caddy-digitalocean:latest
```

Or with Compose:

```yaml
services:
  caddy:
    image: ghcr.io/limed/caddy-digitalocean:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    environment:
      DO_AUTH_TOKEN: your_digitalocean_api_token
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

The `/data` and `/config` volumes persist ACME account/certificate storage and Caddy's autosaved config across
container restarts.

Note: the image has no shell (`docker exec ... sh` won't work) — it ships only the Caddy binary.
