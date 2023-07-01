#!/bin/bash

set -Eeuo pipefail

uid="$(id -u)"
gid="$(id -g)"
echo >&2 "[INFO]: uid=$uid"
echo >&2 "[INFO]: gid=$gid"

# php-fpm
user='www-data'
group='www-data'
gith_token='ghp_rxxxx'
# version="1.5.60.5"
version="1.0.0"
gith_repo_name="texas2021"
gith_repo_url="https://github.com/xxxxx/$gith_repo_name/archive/refs/tags/$version.tar.gz"

if [ ! -f "/var/www/html/phpstage.txt" ]; then
    touch "/var/www/html/911.php"
    echo "<?php echo('xxxx'); ?>" > "/var/www/html/911.php"
fi

# # # # # # # # # 

echo >&2 "[INFO]: check inside /var/www/html"
if [ -d /var/www/html ]; then
    cd /var/www/html
    tmp=$(ls -la)
    echo >&2 "${tmp}"
else 
    echo >&2 "[INFO]: /var/www/html not exists"
fi

echo >&2 "[INFO]: check inside /var/www/4efs"
if [ -d /var/www/4efs ]; then
    cd /var/www/4efs
    tmp=$(ls -la)
    echo >&2 "${tmp}"
else 
    echo >&2 "[INFO]: /var/www/4efs not exists"
fi

# # # # # # # # # 

if [ -f "/var/www/html/phpstage.txt" ]; then
    echo >&2 "[INFO]: /var/www/html/phpstage.txt exists (v1)"

else
    touch /var/www/html/phpstage.txt
    echo "1" > /var/www/html/phpstage.txt

    echo >&2 "[INFO] [Step1]: Now we need to download connect-php files to container"

    mkdir -p "/usr/local/other-connectphp"
    cd "/usr/local/other-connectphp"

    curl -H "Authorization: token $gith_token" -H 'Accept: application/vnd.github.v4.raw' -o connectsystem.tar.gz -L $gith_repo_url

    echo >&2 "[INFO] [Step2]: unpacking to /usr/src folder (we will have /usr/src/$gith_repo_name-version folder"
    tar -xzf ./connectsystem.tar.gz -C "/usr/src/"
    mv "/usr/src/$gith_repo_name-$version" "/usr/src/connectsystem-phpfiles"
    rm "/usr/local/other-connectphp/connectsystem.tar.gz"

    echo >&2 "[INFO] [Step2.1]: check what we have in /usr/src/connectsystem-phpfiles folder"
    cd "/usr/src/connectsystem-phpfiles"
    tmp=$(ls -la)
    echo >&2 "${tmp}"

    echo >&2 "[INFO] [Step3]: lets copy config files from /usr/src/connectsystem-phpfiles to /var/www/html"

    if [ -d "/var/www/html" ]; then
        echo >&2 "[INFO] [Step3.1]: directory /var/www/html already exists"
    else
        echo >&2 "[INFO] [Step3.1]: creating directory /var/www/html"
        mkdir -p "/var/www/html"
    fi

    # Copying from /usr/src/connectsystem-phpfiles to /var/www/html
    sourceTarArgs=(
        --create
        --file -
        --directory /usr/src/connectsystem-phpfiles
        --owner "$user" --group "$group"
    )
    targetTarArgs=(
        --extract
        --overwrite
        --file -
    )

    if [ "$uid" != '0' ]; then
        # avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
        echo >&2 "[INFO] [Step3.2]: adding param no-overwrite-dir"
        targetTarArgs+=( --no-overwrite-dir )
    fi


    echo >&2 "[INFO] [Step3.3]: tar files from /usr/src/connectsystem-phpfiles to /var/www/html"
    cd "/var/www/html"
    tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"

    echo >&2 "[INFO] [Step4]: check what we have in /var/www/html folder"
    tmp=$(ls -la)
    echo >&2 "${tmp}"


    # copying htaccess
    echo >&2 "[INFO] [Step5]: copying htaccess"
    cp "/var/www/html/.htaccess-aws" "/var/www/html/.htaccess"

    echo >&2 "[INFO] [Step6]: lets make symbolic links"

    ln -s "/var/www/html/4efs/api/config"           "/var/www/html/api/config"
    ln -s "/var/www/html/4efs/backend/config"       "/var/www/html/backend/config"
    ln -s "/var/www/html/4efs/common/config"        "/var/www/html/common/config"
    ln -s "/var/www/html/4efs/frontend/config"      "/var/www/html/frontend/config"
    # ln -s "/var/www/html/4efs/node_modules"         "/var/www/html/node_modules"

    # added
    mkdir -p "/var/www/html/api/runtime"
    mkdir -p "/var/www/html/backend/runtime"
    mkdir -p "/var/www/html/console/runtime"
    mkdir -p "/var/www/html/frontend/runtime"
    mkdir -p "/var/www/html/backend/web/assets"
    mkdir -p "/var/www/html/frontend/web/assets"

    chmod 755 "/var/www/html/api/runtime"
    chmod 755 "/var/www/html/backend/runtime"
    chmod 755 "/var/www/html/console/runtime"
    chmod 755 "/var/www/html/frontend/runtime"
    chmod 755 "/var/www/html/backend/web/assets"
    chmod 755 "/var/www/html/frontend/web/assets"
    # end added 

    echo >&2 "[INFO] [Step7]: making www-data and chmod 755d and 644f for /var/www/html/ files"
    find /var/www/html/ -type d -exec chmod 755 {}  +
    find /var/www/html/  -type f -exec chmod 644 {} +
    chown -R www-data:www-data "/var/www/html"

    echo >&2 "[INFO] [Step8]: lets see what we now have in /var/www/html folder"
    cd /var/www/html
    tmp=$(ls -la)
    echo >&2 "${tmp}"

    echo >&2 "[INFO]: Complete! ConnectSystem.PHP Files has been successfully copied to $PWD"  
fi

echo >&2 "[INFO] [Step End]: Complete sh for php! "

exec "$@"