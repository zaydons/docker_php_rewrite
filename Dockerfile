# syntax=docker/dockerfile:1
FROM php:8.3-apache@sha256:d180f417e5e45389d18597150a947d1ce89cad2a60be6c25f54ffcfd40ee05f5

LABEL org.opencontainers.image.source="https://github.com/zaydons/docker_php_rewrite" \
      org.opencontainers.image.description="PHP + Apache image with mod_rewrite and common extensions" \
      org.opencontainers.image.licenses="MIT"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl graphviz; \
    savedAptMark="$(apt-mark showmanual | grep -vE '^(libc6-dev|linux-libc-dev)$')"; \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" gd pdo_mysql mysqli zip opcache; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | grep -v ' ' \
        | sort -u \
        | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY opcache.ini $PHP_INI_DIR/conf.d/zz-opcache.ini

RUN a2enmod headers rewrite \
    && printf '<Directory /var/www/html>\n    AllowOverride All\n</Directory>\n' \
        > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override \
    && printf 'ServerTokens Prod\nServerSignature Off\n' \
        > /etc/apache2/conf-available/security-hardening.conf \
    && a2enconf security-hardening

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sS -o /dev/null http://127.0.0.1/ || exit 1

EXPOSE 80
