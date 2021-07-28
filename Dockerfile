FROM php:7.4-apache
RUN a2enmod headers rewrite
RUN apt-get install libonig-dev
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install xml


