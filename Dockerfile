# use PHP 8.2
FROM php:8.2-fpm

COPY composer.* /var/www/example-app/

WORKDIR /var/www/example-app
RUN apt-get update && apt-get install -y \
build-essential \
libmcrypt-dev \
mariadb-client \
libpng-dev \
libjpeg62-turbo-dev \
libfreetype6-dev \
locales \
zip \
jpegoptim optipng pngquant gifsicle \
vim \
unzip \
git \
curl \
libzip-dev \
zip

# Install Microsoft ODBC Driver for SQL Server and the PHP extensions
RUN apt-get update && apt-get install -y gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get install -y unixodbc-dev \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo pdo_mysql gd zip


# Instal Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www
COPY . .
COPY --chown=www:www . .
USER www

# Jalankan composer install
# RUN composer install --no-interaction --prefer-dist --optimize-autoloader --verbose || true

EXPOSE 9000
CMD [ "php-fpm" ]
