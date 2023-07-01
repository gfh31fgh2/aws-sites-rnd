#!/bin/bash

set -Eeuo pipefail

uid="$(id -u)"
gid="$(id -g)"
echo >&2 "[INFO]: uid=$uid"
echo >&2 "[INFO]: gid=$gid"

# php-fpm
user='www-data'
group='www-data'
gith_token='xxxxx'
version="1.0.2"
gith_repo_name="texas2021"
gith_repo_url="https://github.com/xxxxxxx/$gith_repo_name/archive/refs/tags/$version.tar.gz"


# # # # # # # # # 
# FOR HEALTHCHECK
# # # # # # # # # 
echo >&2 "[INFO] [Stage 1]: Healthcheck"
if [ ! -d /var/www/html/releases/001 ]; then
    mkdir -p "/var/www/html/releases/001"
fi


if [ ! -f "/var/www/html/releases/001/911stage.txt" ]; then
    touch "/var/www/html/releases/001/911stage.txt"
    echo "1" > "/var/www/html/releases/001/911stage.txt"

    touch "/var/www/html/releases/001/911.php"
    echo "<?php echo('nanohealth'); ?>" > "/var/www/html/releases/001/911.php"
fi

echo >&2 "[INFO] [Stage 1]: Completed"
# # # # # # # # # 


# # # # # # # # # 
# FOR APACHE
# # # # # # # # # 
echo >&2 "[INFO] [Stage 2]: Apache"
echo >&2 "[INFO]: check inside /var/www/4efs"
if [ -d /var/www/4efs ]; then
    cd /var/www/4efs
    tmp=$(ls -la)
    echo >&2 "${tmp}"
else 
    echo >&2 "[INFO]: /var/www/4efs not exists"
fi

if [ ! -d "/var/www/4efs/ap2" ]; then
    echo >&2 "[INFO]: Creating /var/www/4efs"
    mkdir -p "/var/www/4efs/ap2"
fi

if [ -d "/var/log/apache2" ]; then
    mkdir -p "/var/www/log/apache2"
fi

# ln -s "/var/log/apache2" "/var/www/4efs/apache2"
ln -sf "/var/www/4efs/ap2/access.log"           "/var/log/apache2/access.log"
ln -sf "/var/www/4efs/ap2/error.log"            "/var/log/apache2/error.log"
ln -sf "/var/www/4efs/ap2/access_log_x.log"     "/var/log/apache2/access_log_x"
ln -sf "/var/www/4efs/ap2/error_log_x.log"      "/var/log/apache2/error_log_x"

echo >&2 "[INFO] [Stage 2]: Completed"
# # # # # # # # # 


# # # # # # # # # 
# FOR PHP-FPM
# # # # # # # # # 
echo >&2 "[INFO] [Stage 3]: PHP-FPM"

echo 'clear_env = no' >> /etc/php/7.4/fpm/pool.d/www.conf
# service php7.4-fpm restart

echo >&2 "[INFO] [Stage 3]: Completed"
# # # # # # # # # 


# # # # # # # # # 
# FOR LINK CURRENT RELEASE
# # # # # # # # # 
# echo >&2 "[INFO] [Stage 4]: Adding link current to /var/www/html/releases/001 release"
# ln -sfn "/var/www/html/releases/001" "/var/www/html/current"
# ln -sfn "$RELEASE_DIR" "$DEPLOY_DIR/current"

echo >&2 "[INFO] [Stage 4]: check inside /var/www/html"
if [ -d /var/www/html ]; then
    cd /var/www/html
    tmp=$(ls -la)
    echo >&2 "${tmp}"
else 
    echo >&2 "[INFO]: /var/www/html not exists"
fi


echo >&2 "[INFO] [Stage 4]: Completed"
# # # # # # # # # 


exec "$@"