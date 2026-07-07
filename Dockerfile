FROM php:8.3-fpm

# Nginx ve gerekli paketler
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install \
    intl \
    mbstring \
    pdo_mysql \
    zip \
    gd \
    opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html/writable

# Nginx konfigurasyonu
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD service nginx start && php-fpm