FROM httpd:2.4
MAINTAINER xxxxx <xxxx@xxxxx.ru>

RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        build-essential \
        cron \
        iputils-ping \
        git \
        nano \
        curl \
        net-tools \
        zip \
        unzip \
        tar \
        wget \
        libxml2-dev 

# Deleting default configs
RUN rm /usr/local/apache2/conf/extra/*.conf \
    && mkdir /usr/local/apache2/conf/sites/

# Coping our config of httpd
COPY emconnect-httpd.conf /usr/local/apache2/conf/httpd.conf

# Adding our config
ADD emconnect-dev.conf /usr/local/apache2/conf/sites/emconnect-dev.conf

# LOGS to stderr stdout
# RUN mkdir -p /var/log/apache2/ \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/error.log \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/access_log_x \
#     && ln -sf /proc/self/fd/1 /var/log/apache2/error_log_x

# FOR TESTING
RUN mkdir -p /var/log/apache2/ \
    && mkdir -p /var/www/4efs/apache2 
    # && ln -sf /var/www/html/4efs/ap2/a.log /var/log/apache2/access.log \
    # && ln -sf /var/www/html/4efs/ap2/e.log /var/log/apache2/error.log \
    # && ln -sf /var/www/html/4efs/ap2/ax.log /var/log/apache2/access_log_x \
    # && ln -sf /var/www/html/4efs/ap2/ex.log /var/log/apache2/error_log_x

# FOR MOD_CACHE CREATING FOLDER
RUN mkdir -p /var/cache/httpd/proxy


ADD connect-system /usr/src/connectsystemconfig/

WORKDIR /var/www/html/
VOLUME /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 0777 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]