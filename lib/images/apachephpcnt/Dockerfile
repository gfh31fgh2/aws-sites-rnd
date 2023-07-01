FROM ubuntu:20.04
MAINTAINER xxxx <xxxxx@xxxx.ru>
ENV DEBIAN_FRONTEND=noninteractive \
    APACHE_DOCUMENT_ROOT=/var/www/html/current

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
        libzip-dev \
        libwebp-dev \
        libgd-dev \
        libxpm-dev \
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
        nodejs \
        libldap2-dev \
        rsync

# APACHE 
RUN apt-get update \
    && apt-get install -y \
        apache2 \
        apache2-bin \
        apache2-data \
        apache2-utils \
        libapr1 \
        libaprutil1 \
        libaprutil1-dbd-sqlite3 \
        libaprutil1-ldap \
        liblua5.2-0 \
        ssl-cert \
    && apt-get install -y libapache2-mod-php7.4 

# PHP
RUN apt-get update \
    && apt-get install -y \
    php7.4-fpm \
    php7.4-cli \
    php7.4-gd \
    php7.4-intl \
    php7.4-zip \
    php7.4-mysqli \
    php7.4-pdo \
    php7.4-mbstring \
    php7.4-exif \
    php7.4-bcmath \
    php7.4-xml \
    php7.4-ldap \
    php7.4-sockets \
    php7.4-opcache \
    php7.4-curl \
    php7.4-dev \
    php-pear \
    php7.4-gmp \
    php7.4-soap \
    && apt-get install -y libapache2-mod-php7.4 

RUN pecl install mcrypt

# PHP.INI
# ADD ./php.ini /usr/local/etc/php/php.ini
ADD ./php.ini /etc/php/7.4/fpm/php.ini


# SUPERVISOR  
RUN apt-get update \
    && apt-get install -y \
        supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir /var/log/supervisord

# Add supervisor configuration
ADD supervisor-apache.conf /etc/supervisor/conf.d/supervisor-apache.conf
ADD supervisor-phpfpm.conf /etc/supervisor/conf.d/supervisor-phpfpm.conf
ADD supervisor-cron.conf /etc/supervisor/conf.d/supervisor-cron.conf


# COMPOSER
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# CLEANING
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# LOGS to stderr stdout
# RUN mkdir -p /var/log/apache2/ \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/error.log \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/access_log_x \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/error_log_x

# FOR LOGS ON EFS
RUN mkdir -p /var/log/apache2/ \
    && mkdir -p /var/www/4efs/apache2 \
    && mkdir -p /var/www/ctab/ \
    && mkdir -p /var/www/html/releases/001


# # Deleting default configs
# RUN rm /usr/local/apache2/conf/extra/*.conf \
#     && mkdir /usr/local/apache2/conf/sites/

# Coping our config of httpd
COPY emconnect-httpd.conf /usr/local/apache2/conf/httpd.conf

# Adding our config
RUN rm /etc/apache2/sites-available/*.conf
RUN rm /etc/apache2/sites-enabled/*.conf
ADD emconnect-dev.conf /etc/apache2/sites-available/emconnect-dev.conf

# Enable Apache mods.
#RUN a2enmod rewrite headers fcgid alias proxy_fcgi
RUN a2enmod rewrite headers alias proxy_fcgi ldap vhost_alias cgi
RUN a2ensite emconnect-dev

ADD connect-system /usr/src/connectsystemconfig/


# CRON CHECK_GIT AND MORE
#
ADD checkgit.sh /var/www/ctab/
RUN chmod 0744 /var/www/ctab/checkgit.sh
ADD begin.sh /var/www/ctab/
RUN chmod 0744 /var/www/ctab/begin.sh
# Copy hello-cron file to the cron.d directory
COPY cron_checkgit /etc/cron.d/cron_checkgit

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron_checkgit

# Apply cron job
RUN crontab /etc/cron.d/cron_checkgit

# Create the log file to be able to run tail
RUN touch /var/log/cron.log
#
# end CRON CHECK_GIT AND MORE

RUN ln -s /var/www/html/releases/001 /var/www/html/current

WORKDIR /var/www/html/current/
VOLUME /var/www/html/current

RUN service php7.4-fpm start

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 0777 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord", "-n"]

# CMD ["apache2ctl", "-D", "FOREGROUND"]