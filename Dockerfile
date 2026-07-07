FROM php:8.3-apache

# Gerekli extension'lar
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install intl mbstring pdo_mysql zip gd opcache

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html/writable

# Apache config
RUN a2enmod rewrite
COPY .htaccess /var/www/html/public/.htaccess
# .htaccess için izin
RUN cp public/.htaccess public/.htaccess 2>/dev/null || true

EXPOSE 80