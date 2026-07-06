# syntax=docker/dockerfile:1
FROM php:8.3-apache@sha256:d180f417e5e45389d18597150a947d1ce89cad2a60be6c25f54ffcfd40ee05f5

LABEL org.opencontainers.image.source="https://github.com/zaydons/docker_php_rewrite" \
      org.opencontainers.image.description="PHP + Apache image with mod_rewrite and common extensions" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        graphviz \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mysqli zip opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY opcache.ini $PHP_INI_DIR/conf.d/zz-opcache.ini

RUN a2enmod headers rewrite \
    && printf '<Directory /var/www/html>\n    AllowOverride All\n</Directory>\n' \
        > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override

EXPOSE 80
