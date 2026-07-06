# docker_php_rewrite

PHP + Apache Docker image with `mod_rewrite` enabled and common extensions preinstalled. Started life as "just enable mod_rewrite" — turned into a modest batteries-included base image.

## What's inside

- Base: `php:8.3-apache`
- Apache modules: `mod_rewrite`, `mod_headers`
- `AllowOverride All` on `/var/www/html` — `.htaccess` files work out of the box
- PHP extensions: `gd` (with freetype + jpeg), `pdo_mysql`, `mysqli`, `zip`
- System packages: `graphviz`
- Multi-arch: `linux/amd64`, `linux/arm64`

## Usage

Pull:

```sh
docker pull ghcr.io/zaydons/docker_php_rewrite:latest
```

Run against a local project:

```sh
docker run --rm -p 8080:80 -v "$PWD":/var/www/html \
  ghcr.io/zaydons/docker_php_rewrite:latest
```

Open <http://localhost:8080>.

## Building locally

```sh
docker build -t docker_php_rewrite .
```

## Tags

Published to `ghcr.io/zaydons/docker_php_rewrite`:

- `latest` — head of `main`
- `main` — same as latest
- `pr-<n>` — per pull request build
- `sha-<short>` — per commit
- `X.Y.Z`, `X.Y` — on git tags matching semver
