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

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/public

# Apache config
RUN a2enmod rewrite \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && printf '%s\n' \
        '<VirtualHost *:80>' \
        '    DocumentRoot /var/www/html/public' \
        '    <Directory /var/www/html/public>' \
        '        Options FollowSymLinks' \
        '        AllowOverride All' \
        '        Require all granted' \
        '    </Directory>' \
        '</VirtualHost>' \
        > /etc/apache2/sites-available/000-default.conf

EXPOSE 80