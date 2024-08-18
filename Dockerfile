# Menggunakan image PHP dengan Apache
FROM php:7.2-apache

# Install ekstensi yang dibutuhkan Laravel
RUN apt-get update && apt-get install -y \
    apt-utils \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install node dan npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs 

# Menyalin source code Laravel dan React ke container
COPY . /var/www/html

# Atur direktori kerja untuk Laravel
WORKDIR /var/www/html

# Atur kepemilikan dan izin direktori
RUN chown -R www-data:www-data /var/www/

# Install dependensi Laravel
USER www-data
RUN composer clear-cache
RUN composer update --prefer-dist

# buat env file dalam container
RUN cp .env.example .env
RUN php artisan key:generate

# Install dependensi node dan build assets
RUN npm install && npm run prod

# Set hak akses untuk storage dan bootstrap
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public

#enable rewrite module
USER root
RUN a2enmod rewrite

#change documentroot
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-enabled/000-default.conf

# Expose port
EXPOSE 80
