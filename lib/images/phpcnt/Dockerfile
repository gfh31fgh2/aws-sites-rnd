FROM php:7.4-fpm
MAINTAINER xxxx <xxxx@xxxx.ru>
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        build-essential \
        wget \
        autoconf \
        cron \
        iputils-ping \
        g++ \
        default-mysql-client \
        default-libmysqlclient-dev \
        git \
        curl \
        dpkg-dev \
        libpng-dev \
        libjpeg-dev \
        libonig-dev \
        libxml2-dev \
        libpq-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libzip-dev \
        libwebp-dev \
        libgd-dev \
        libxpm-dev \
        cron \
        libmcrypt-dev \
        zlib1g-dev \
        libbz2-dev \
        libssl-dev \
        libicu-dev \
        libfreetype6-dev \
        redis \
        net-tools \
        zip \
        unzip \
        nano \
        sass \
        ruby-sass \
        nodejs 


# PHP gd and intl
# RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-gd --with-jpeg-dir --with-png-dir --with-zlib-dir
RUN docker-php-ext-configure gd

RUN docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure intl && docker-php-ext-install intl 

# PHP ext
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd sockets zip

# LDAP
RUN apt-get install -y libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap

# OPCACHE
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

# COMPOSER
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# CLEANING
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP.INI
ADD ./php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html
# USER dev

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 0777 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]