#!/bin/bash

set -Eeuo pipefail

# first check for begin
if [ ! -f "/var/www/ctab/begin.txt" ]; then
    touch "/var/www/ctab/begin.txt"
    echo "1" > "/var/www/ctab/begin.txt"
else
    exit 1
fi

uid="$(id -u)"
gid="$(id -g)"
echo >&2 "[INFO]: uid=$uid"
echo >&2 "[INFO]: gid=$gid"

# php-fpm
user='www-data'
group='www-data'
gith_token='xxxxxx'
version="1.0.2"
gith_repo_name="texas2021"
gith_repo_url="https://github.com/xxxxxx/$gith_repo_name/archive/refs/tags/$version.tar.gz"

# # # # # # # # # 

echo >&2 "[INFO]: check inside /usr/src"
cd /usr/src
tmp=$(ls -la)
echo >&2 "${tmp}"

echo >&2 "[INFO]: check inside /var/www/html/releases/001"
if [ -d /var/www/html/releases/001 ]; then
    cd /var/www/html/releases/001
    tmp=$(ls -la)
    echo >&2 "${tmp}"
else 
    echo >&2 "[INFO]: /var/www/html/releases/001 not exists"
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

echo >&2 "[INFO]: lets make some special work!"


if [ ! -d "/var/www/4efs/ap2" ]; then
    mkdir -p "/var/www/4efs/ap2"
fi

if [ -d "/var/log/apache2" ]; then
    mkdir -p "/var/www/log/apache2"
fi


if [ ! -d "/var/www/4efs/api/config" ]; then
    echo >&2 "[INFO] [Step005]: lets create directories for configs in /var/www/4efs folder"

    mkdir -p "/var/www/4efs/api/config/"
    mkdir -p "/var/www/4efs/backend/config/"
    mkdir -p "/var/www/4efs/common/config/"
    mkdir -p "/var/www/4efs/frontend/config/"

fi

if [ ! -d "/var/www/4efs/api/runtime" ]; then
    echo >&2 "[INFO] [Step005]: lets create assets and runtime in /var/www/4efs folder"

    mkdir -p "/var/www/4efs/api/runtime/"
    mkdir -p "/var/www/4efs/console/runtime/"
    mkdir -p "/var/www/4efs/backend/runtime/"
    mkdir -p "/var/www/4efs/frontend/runtime/"

    mkdir -p "/var/www/4efs/backend/web/assets/"
    mkdir -p "/var/www/4efs/frontend/web/assets/"
fi


# # # # # # # # # 


echo >&2 "[INFO] [Stage 1]: Apache stage! "

if [ -f "/var/www/4efs/apachestage.txt" ]; then
    echo >&2 "[INFO]: /var/www/4efs/apachestage.txt exists (v8)"
else 
    touch "/var/www/4efs/apachestage.txt"
    echo "1" > "/var/www/4efs/apachestage.txt"

    echo >&2 "[INFO] [Step0.1]: check what we have in /usr/src/connectsystemconfig folder"
    cd "/usr/src/connectsystemconfig"
    tmp=$(ls -la)
    echo >&2 "${tmp}"

    echo >&2 "[INFO] [Step1]: lets replace variables in /usr/src/connectsystemconfig"

    # Changing variables in config files main.php or main-local.php
    # API VARIABLES
    CS_API[0]="__REPLACE_CS_API_COOKIE__"
    REPLACE_CS_API[0]="9XzTxw-VH2NvlchdPns-r9YbgZpMvu49"

    # BACKEND VARIABLES
    CS_BACKEND[0]="__REPLACE_CS_BACKEND_COOKIE__"
    REPLACE_CS_BACKEND[0]="Uxk5An4i7KXyIB7-NtLDkyXs-unD0q7q"

    # COMMON VARIABLES
    CS_COMMON[0]="__REPLACE_CS_COMMON_INFRA1_ADMIN_USERNAME__"
    REPLACE_CS_COMMON[0]="xxxx"
    CS_COMMON[1]="__REPLACE_CS_COMMON_INFRA1_ADMIN_PASSWORD__"
    REPLACE_CS_COMMON[1]="xxxxxx"
    CS_COMMON[2]="__REPLACE_CS_COMMON_INFRA2_ADMIN_USERNAME__"
    REPLACE_CS_COMMON[2]="xxxxx"
    CS_COMMON[3]="__REPLACE_CS_COMMON_INFRA2_ADMIN_PASSWORD__"
    REPLACE_CS_COMMON[3]="xxxxx"

    # FRONTEND VARIABLES MAIN.PHP
    CS_FRONTEND_MAIN[0]="__REPLACE_CS_FRONTEND_MAIN_COOKIE__"
    REPLACE_CS_FRONTEND_MAIN[0]="xxxxx"

    # FRONTEND VARIABLES MAIN-LOCAL.PHP
    CS_FRONTEND_MAIN_LOCAL[0]="__REPLACE_CS_FRONTEND_MAIN_LOCAL_COOKIE__"
    REPLACE_CS_FRONTEND_MAIN_LOCAL[0]="xxxxx"

    # BOOTSTRAP VARIABLES COMMON/CONFIG/BOOTSTRAP.PHP
    CS_COMMON_BOOTSTRAP[0]="{yii_env}"
    REPLACE_CS_COMMON_BOOTSTRAP[0]="dev"
    CS_COMMON_BOOTSTRAP[1]="{yii_debug}"
    REPLACE_CS_COMMON_BOOTSTRAP[1]="true"

    # Replacing vars in configs in /usr/src/connectsystemconfig/
    arraylength1=${#CS_API[@]}
    for (( i=0; i<${arraylength1}; i++ )); do
        echo >&2 "[INFO]: api cycle, $i"
        sed -i 's/'"${CS_API[$i]}"'/'"${REPLACE_CS_API[$i]}"'/g' /usr/src/connectsystemconfig/api/config/main.php
    done

    arraylength2=${#CS_BACKEND[@]}
    for (( i=0; i<${arraylength2}; i++ )); do
        echo >&2 "[INFO]: backend cycle, $i"
        sed -i 's/'"${CS_BACKEND[$i]}"'/'"${REPLACE_CS_BACKEND[$i]}"'/g' /usr/src/connectsystemconfig/backend/config/main.php
    done

    arraylength3=${#CS_COMMON[@]}
    for (( i=0; i<${arraylength3}; i++ )); do
        echo >&2 "[INFO]: common cycle, $i"
        sed -i 's/'"${CS_COMMON[$i]}"'/'"${REPLACE_CS_COMMON[$i]}"'/g' /usr/src/connectsystemconfig/common/config/main.php
    done

    arraylength4=${#CS_FRONTEND_MAIN[@]}
    for (( i=0; i<${arraylength4}; i++ )); do
        echo >&2 "[INFO]: frontend cycle1, $i"
        sed -i 's/'"${CS_FRONTEND_MAIN[$i]}"'/'"${REPLACE_CS_FRONTEND_MAIN[$i]}"'/g' /usr/src/connectsystemconfig/frontend/config/main.php
    done

    arraylength5=${#CS_FRONTEND_MAIN_LOCAL[@]}
    for (( i=0; i<${arraylength5}; i++ )); do
        echo >&2 "[INFO]: frontend cycle2, $i"
        sed -i 's/'"${CS_FRONTEND_MAIN_LOCAL[$i]}"'/'"${REPLACE_CS_FRONTEND_MAIN_LOCAL[$i]}"'/g' /usr/src/connectsystemconfig/frontend/config/main-local.php
    done

    arraylength6=${#CS_COMMON_BOOTSTRAP[@]}
    for (( i=0; i<${arraylength6}; i++ )); do
        echo >&2 "[INFO]: common-boostrap cycle, $i"
        sed -i 's/'"${CS_COMMON_BOOTSTRAP[$i]}"'/'"${REPLACE_CS_COMMON_BOOTSTRAP[$i]}"'/g' /usr/src/connectsystemconfig/common/config/bootstrap.php
    done

    # end replacing

    echo >&2 "[INFO] [Step2]: lets copy config files from /usr/src/connectsystemconfig to /var/www/4efs"

    if [ -d "/var/www/4efs" ]; then
        echo >&2 "[INFO] [Step2.1]: directory /var/www/4efs already exists"
    else
        echo >&2 "[INFO] [Step2.1]: creating directory /var/www/4efs "
        mkdir -p "/var/www/4efs"
    fi

    # Copying from /usr/src/connectsystemconfig to /var/www/4efs
    sourceTarArgs=(
        --create
        --file -
        --directory /usr/src/connectsystemconfig
        --owner "$user" --group "$group"
    )
    targetTarArgs=(
        --extract
        --overwrite
        --file -
    )

    if [ "$uid" != '0' ]; then
        # avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
        echo >&2 "[INFO] [Step2.2]: adding param no-overwrite-dir"
        targetTarArgs+=( --no-overwrite-dir )
    fi

    echo >&2 "[INFO] [Step3]: copying files from /usr/src/connectsystemconfig to /var/www/4efs"
    cd "/var/www/4efs"
    tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
    # tar -cf - . | ( cd "/var/www/html/releases/001"; tar xfh - )
    # tar cvf connsystem.tar .
    # tar -cf - . | ( cd "/var/www/html/4efs"; tar xfh - )
    echo >&2 "[INFO] [Step3.1]: made tar archive"
    # tar xvfh "/usr/src/connectsystemconfig/connsystem.tar"

    cd "/var/www/4efs"
    echo >&2 "[INFO] [Step4]: check what we have in /var/www/4efs folder"
    tmp=$(ls -la)
    echo >&2 "${tmp}"


    echo >&2 "[INFO] [Step5]: making www-data and chmod 755d and 644f for /var/www/4efs files"
    find /var/www/4efs/ -type d -exec chmod 755 {}  +
    find /var/www/4efs/  -type f -exec chmod 644 {} +
    chown -R www-data:www-data "/var/www/4efs"
    
    echo >&2 "[INFO] [Step6]: lets see what we now have in /var/www/4efs folder"
    cd /var/www/4efs
    tmp=$(ls -la)
    echo >&2 "${tmp}"


    echo >&2 "[INFO] [Step7]: copy all configs to /var/www/html/releases/001 folder"

    if [ -d "/var/www/html/releases/001/api/config" ]; then
        rm -r "/var/www/html/releases/001/api/config"
    fi

    if [ -d "/var/www/html/releases/001/backend/config" ]; then
        rm -r "/var/www/html/releases/001/backend/config"
    fi

    if [ -d "/var/www/html/releases/001/common/config" ]; then
        rm -r "/var/www/html/releases/001/common/config"
    fi

    if [ -d "/var/www/html/releases/001/frontend/config" ]; then
        rm -r "/var/www/html/releases/001/frontend/config"
    fi

    mkdir -p "/var/www/html/releases/001/api/config"
    mkdir -p "/var/www/html/releases/001/backend/config"
    mkdir -p "/var/www/html/releases/001/common/config"
    mkdir -p "/var/www/html/releases/001/frontend/config"
    cp -a /var/www/4efs/api/config/.      /var/www/html/releases/001/api/config/
    cp -a /var/www/4efs/backend/config/.  /var/www/html/releases/001/backend/config/
    cp -a /var/www/4efs/common/config/.   /var/www/html/releases/001/common/config/
    cp -a /var/www/4efs/frontend/config/. /var/www/html/releases/001/frontend/config/

    echo >&2 "[INFO]: Complete! ConnectSystem.Config Files has been successfully copied to /var/www/html/releases/001/api-backend-common-frontend/config"
fi

# # # # # # # # # 

echo >&2 "[INFO] [Stage 1: End]: Complete sh for apache! "

# # # # # # # # # 


if [ ! -d "/var/www/html/releases/001/api/config" ]; then
    echo >&2 "[INFO] [Step-mid]: copy all configs to local folder"

    if [ -d "/var/www/html/releases/001/api/config" ]; then
        rm -r "/var/www/html/releases/001/api/config" 
    fi

    if [ -d "/var/www/html/releases/001/backend/config" ]; then
        rm -r "/var/www/html/releases/001/backend/config"
    fi

    if [ -d "/var/www/html/releases/001/common/config" ]; then
        rm -r "/var/www/html/releases/001/common/config"
    fi

    if [ -d "/var/www/html/releases/001/frontend/config" ]; then
        rm -r "/var/www/html/releases/001/frontend/config"
    fi

    mkdir -p "/var/www/html/releases/001/api/config"
    mkdir -p "/var/www/html/releases/001/common/config"
    mkdir -p "/var/www/html/releases/001/backend/config"
    mkdir -p "/var/www/html/releases/001/frontend/config"

    # cp -r "/var/www/4efs/api/config/"      "/var/www/html/releases/001/api/config/"
    # cp -r "/var/www/4efs/backend/config/"  "/var/www/html/releases/001/backend/config/"
    # cp -r "/var/www/4efs/common/config/"   "/var/www/html/releases/001/common/config/"
    # cp -r "/var/www/4efs/frontend/config/" "/var/www/html/releases/001/frontend/config/"

    if [ -d "/var/www/html/releases/001/api/config/" ]; then
        cp -a "/var/www/4efs/api/config/."      "/var/www/html/releases/001/api/config/"
        chown -R www-data:www-data "/var/www/html/releases/001/api/config/"
    else
        echo >&2 "[INFO] havent got folder /var/www/html/releases/001/api/config/"
    fi

    if [ -d "/var/www/html/releases/001/backend/config/" ]; then
        cp -a "/var/www/4efs/backend/config/."  "/var/www/html/releases/001/backend/config/"
        chown -R www-data:www-data "/var/www/html/releases/001/backend/config/"
    else
        echo >&2 "[INFO] havent got folder /var/www/html/releases/001/backend/config/"
    fi

    if [ -d "/var/www/html/releases/001/common/config/" ]; then
        cp -a "/var/www/4efs/common/config/."   "/var/www/html/releases/001/common/config/"
        chown -R www-data:www-data "/var/www/html/releases/001/common/config/"
    else
        echo >&2 "[INFO] havent got folder /var/www/html/releases/001/common/config/"
    fi

    if [ -d "/var/www/html/releases/001/frontend/config/" ]; then
        cp -a "/var/www/4efs/frontend/config/." "/var/www/html/releases/001/frontend/config/"
        chown -R www-data:www-data "/var/www/html/releases/001/frontend/config/" 
    else
        echo >&2 "[INFO] havent got folder /var/www/html/releases/001/frontend/config/"
    fi

fi

echo >&2 "[INFO] [Stage 1.5]: PHP stage! "
if [ -f "/var/www/4efs/connectsystem.tar.gz" ]; then
    echo >&2 "[INFO]: /var/www/4efs/connectsystem-with-config.tar.gz exists!"
fi


echo >&2 "[INFO] [Stage 2]: PHP stage! "

if [ -f "/var/www/html/releases/001/phpstage.txt" ]; then
    echo >&2 "[INFO]: /var/www/html/releases/001/phpstage.txt exists (v1)"

else
    touch /var/www/html/releases/001/phpstage.txt
    echo "1" > /var/www/html/releases/001/phpstage.txt

    echo >&2 "[INFO] [Step1]: Now we need to download connect-php files to container"

    mkdir -p "/usr/local/other-connectphp"
    cd "/usr/local/other-connectphp"

    curl -H "Authorization: token $gith_token" -H 'Accept: application/vnd.github.v4.raw' -o connectsystem.tar.gz -L $gith_repo_url

    # cp "/usr/local/other-connectphp/connectsystem.tar.gz" "/var/www/4efs/connectsystem.tar.gz"

    echo >&2 "[INFO] [Step2]: unpacking (+) to /usr/src folder (we will have /usr/src/$gith_repo_name-version folder)"
    # tar -xzf ./connectsystem.tar.gz -C "/usr/src/"
    # tar -xf ./connectsystem.tar.gz -C "/usr/src/"
    tar -xzf ./connectsystem.tar.gz -C "/usr/src/"
    mv "/usr/src/$gith_repo_name-$version" "/usr/src/connectsystem-phpfiles"
    rm "/usr/local/other-connectphp/connectsystem.tar.gz"

    echo >&2 "[INFO] [Step2.1]: check what we have in /usr/src/connectsystem-phpfiles folder"
    cd "/usr/src/connectsystem-phpfiles"
    tmp=$(ls -la)
    echo >&2 "${tmp}"


    echo >&2 "[INFO] [Step3]: lets copy config files from /usr/src/connectsystem-phpfiles to /var/www/html"

    if [ -d "/var/www/html/releases/001" ]; then
        echo >&2 "[INFO] [Step3.1]: directory /var/www/html/releases/001 already exists"
    else
        echo >&2 "[INFO] [Step3.1]: creating directory /var/www/html/releases/001"
        mkdir -p "/var/www/html/releases/001"
    fi

    # Copying from /usr/src/connectsystem-phpfiles to /var/www/html/releases/001
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
    cd "/var/www/html/releases/001"
    tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"

    echo >&2 "[INFO] [Step4]: check what we have in /var/www/html/releases/001 folder"
    tmp=$(ls -la)
    echo >&2 "${tmp}"


    # copying htaccess
    echo >&2 "[INFO] [Step5]: copying htaccess"
    cp "/var/www/html/releases/001/.htaccess-aws" "/var/www/html/releases/001/.htaccess"

    echo >&2 "[INFO] [Step6.1]: making symbolic links"
    # making symbolic links

    if [ -d "/var/www/html/releases/001/api/runtime" ]; then
        rm -r "/var/www/html/releases/001/api/runtime"
    fi

    if [ -d "/var/www/html/releases/001/console/runtime" ]; then
        rm -r "/var/www/html/releases/001/console/runtime"
    fi

    if [ -d "/var/www/html/releases/001/backend/runtime" ]; then
        rm -r "/var/www/html/releases/001/backend/runtime"
    fi

    if [ -d "/var/www/html/releases/001/frontend/runtime" ]; then
        rm -r "/var/www/html/releases/001/frontend/runtime"
    fi
    
    # ln -sf "/var/www/4efs/api/runtime"      "/var/www/html/releases/001/api/runtime"
    # ln -sf "/var/www/4efs/console/runtime"  "/var/www/html/releases/001/console/runtime"
    # ln -sf "/var/www/4efs/backend/runtime"  "/var/www/html/releases/001/backend/runtime"
    # ln -sf "/var/www/4efs/frontend/runtime" "/var/www/html/releases/001/frontend/runtime"

    if [ -d "/var/www/html/releases/001/frontend/web/assets" ]; then
        rm -r "/var/www/html/releases/001/frontend/web/assets"
    fi

    if [ -d "/var/www/html/releases/001/backend/web/assets" ]; then
        rm -r "/var/www/html/releases/001/backend/web/assets"
    fi

    # ln -sf "/var/www/4efs/frontend/web/assets"  "/var/www/html/releases/001/frontend/web/assets"
    # ln -sf "/var/www/4efs/backend/web/assets"   "/var/www/html/releases/001/backend/web/assets"

    # for testing 1 coutnaienr
    mkdir -p "/var/www/html/releases/001/api/runtime"
    mkdir -p "/var/www/html/releases/001/console/runtime"
    mkdir -p "/var/www/html/releases/001/backend/runtime"
    mkdir -p "/var/www/html/releases/001/frontend/runtime"

    mkdir -p "/var/www/html/releases/001/frontend/web/assets"
    mkdir -p "/var/www/html/releases/001/backend/web/assets"

    chown -R www-data:www-data "/var/www/html/releases/001/api/runtime"
    chown -R www-data:www-data "/var/www/html/releases/001/console/runtime"
    chown -R www-data:www-data "/var/www/html/releases/001/backend/runtime"
    chown -R www-data:www-data "/var/www/html/releases/001/frontend/runtime"

    chown -R www-data:www-data "/var/www/html/releases/001/frontend/web/assets"
    chown -R www-data:www-data "/var/www/html/releases/001/backend/web/assets"
    # end


    echo >&2 "[INFO] [Step6.2]: making www-data and chmod 755d and 644f for /var/www/html/releases/001/ files"
    # make all www-data
    find /var/www/html/releases/001/ -type d -exec chmod 755 {}  +
    find /var/www/html/releases/001/  -type f -exec chmod 644 {} +
    chown -R www-data:www-data "/var/www/html/releases/001"

    echo >&2 "[INFO] [Step6.3]: lets see what we now have in /var/www/html/releases/001/api/ folder"
    cd /var/www/html/releases/001/api/
    tmp=$(ls -la)
    echo >&2 "${tmp}"

    echo >&2 "[INFO] [Step7]: lets see what we now have in /var/www/html/releases/001 folder"
    cd /var/www/html/releases/001
    tmp=$(ls -la)
    echo >&2 "${tmp}"

    tar -czf /var/www/4efs/connectsystem-with-config.tar.gz /var/www/html/releases/001

    echo >&2 "[INFO]: Complete! ConnectSystem.PHP Files has been successfully copied to $PWD"  
fi




echo >&2 "[INFO] [Stage 4]: Chmod +х to /var/www/html/releases/001/common/modules/Autoprefixer/js/node_modules/postcss-cli/bin/postcss"

if [ -f "/var/www/html/releases/001/common/modules/Autoprefixer/js/node_modules/postcss-cli/bin/postcss" ]; then
    chmod +x "/var/www/html/releases/001/common/modules/Autoprefixer/js/node_modules/postcss-cli/bin/postcss"
    echo >&2 "[INFO] [Stage 4.1]: [OK]"
fi


echo >&2 "[INFO] [Stage 5]: Chmod 0777 for assets"

if [ -d "/var/www/4efs/frontend/runtime/themes/tswfm/widgets/NavItems/assets" ]; then
    chmod -R 0777 /var/www/4efs/frontend/runtime/themes/tswfm/widgets/NavItems/assets
    echo >&2 "[INFO] [Stage 5.1]: [OK]"
fi

if [ -d "/var/www/4efs/frontend/runtime/themes/tswfm/widgets/SlickBannerWidget/assets" ]; then
    chmod -R 0777 /var/www/4efs/frontend/runtime/themes/tswfm/widgets/SlickBannerWidget/assets
    echo >&2 "[INFO] [Stage 5.2]: [OK]"
fi

if [ -d "/var/www/4efs/frontend/runtime/themes/tswfm/widgets/ArticlesWidget/assets" ]; then
    chmod -R 0777 /var/www/4efs/frontend/runtime/themes/tswfm/widgets/ArticlesWidget/assets
    echo >&2 "[INFO] [Stage 5.3]: [OK]"
fi

if [ -d "/var/www/4efs/frontend/runtime/themes/tswfm/widgets/SearchRequestWidget/assets" ]; then
    chmod -R 0777 /var/www/4efs/frontend/runtime/themes/tswfm/widgets/SearchRequestWidget/assets
    echo >&2 "[INFO] [Stage 5.4]: [OK]"
fi

if [ -d "/var/www/html/releases/001/vendor/yiisoft/yii2/assets" ]; then
    chmod -R 0777 /var/www/html/releases/001/vendor/yiisoft/yii2/assets
    echo >&2 "[INFO] [Stage 5.5]: [OK]"
fi

if [ -d "/var/www/html/releases/001/frontend/runtime/themes/tswfm/assets/theme" ]; then
    chmod -R 0777 /var/www/html/releases/001/frontend/runtime/themes/tswfm/assets/theme
    echo >&2 "[INFO] [Stage 5.6]: [OK]"
fi

echo >&2 "[INFO] [Stage 5]: Completed"

# echo >&2 "[INFO]: lets remove line from crontab"
# tmp_crontab=$(crontab -l | grep -v '* * * * * /bin/bash /var/www/ctab/begin.sh > /proc/1/fd/1 2>/proc/1/fd/2' | crontab -)
# echo >&2 "${tmp_crontab}"
# crontab -l | grep -v '<SPECIFICS OF YOUR SCRIPT HERE>' | crontab -
# echo >&2 "[INFO]: begin sh from crontab removed"


# THIS IS NOT NEEDED!!! DONT OPEN IT!
# echo >&2 "[INFO] [Stage 6]: Adding link current to /var/www/html/releases/001 release"
# ln -sfn "/var/www/html/releases/001" "/var/www/html/current"
# ln -sfn "$RELEASE_DIR" "$DEPLOY_DIR/current"
# echo >&2 "[INFO] [Stage 6]: Completed"



# exec "$@"