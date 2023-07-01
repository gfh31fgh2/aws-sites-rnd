#!/bin/bash

set -Eeuo pipefail

uid="$(id -u)"
gid="$(id -g)"
echo >&2 "[INFO]: uid=$uid"
echo >&2 "[INFO]: gid=$gid"

# php-fpm
user='www-data'
group='www-data'

# # # # # # # # # 

echo >&2 "[INFO]: check inside /usr/src"
cd /usr/src
tmp=$(ls -la)
echo >&2 "${tmp}"

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

echo >&2 "[INFO]: lets make some special work!"


if [ -d "/var/www/4efs/apache2" ]; then
    mkdir -p "/var/www/4efs/apache2"
fi

if [ -d "/var/log/apache2" ]; then
    mkdir -p "/var/www/log/apache2"
fi

ln -s "/var/www/4efs/apache2" "/var/log/apache2"

if [ ! -d "/var/www/4efs/api/config" ]; then
    echo >&2 "[INFO] [Step005]: lets create directories for configs in /var/www/4efs folder"

    mkdir -p "/var/www/4efs/api/config/"
    mkdir -p "/var/www/4efs/backend/config/"
    mkdir -p "/var/www/4efs/common/config/"
    mkdir -p "/var/www/4efs/frontend/config/"

fi

# if [ ! -d "/var/www/html/4efs/api/runtime" ]; then
#     echo >&2 "[INFO] [Step005]: lets create directories runtime and assets in /var/www/html/4efs folder"

#     mkdir -p "/var/www/html/4efs/api/config/"
#     mkdir -p "/var/www/html/4efs/backend/config/"
#     mkdir -p "/var/www/html/4efs/common/config/"
#     mkdir -p "/var/www/html/4efs/frontend/config/"

#     mkdir -p "/var/www/html/4efs/api/runtime/"
#     mkdir -p "/var/www/html/4efs/console/runtime/"
#     mkdir -p "/var/www/html/4efs/backend/runtime/"
#     mkdir -p "/var/www/html/4efs/frontend/runtime/"

#     mkdir -p "/var/www/html/4efs/backend/web/assets/"
#     mkdir -p "/var/www/html/4efs/frontend/web/assets/"
# fi

# # # # # # # # # 

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
    REPLACE_CS_API[0]="xxxxxxx"

    # BACKEND VARIABLES
    CS_BACKEND[0]="__REPLACE_CS_BACKEND_COOKIE__"
    REPLACE_CS_BACKEND[0]="xxxxx"

    # COMMON VARIABLES
    CS_COMMON[0]="__REPLACE_CS_COMMON_INFRA1_ADMIN_USERNAME__"
    REPLACE_CS_COMMON[0]="xxx"
    CS_COMMON[1]="__REPLACE_CS_COMMON_INFRA1_ADMIN_PASSWORD__"
    REPLACE_CS_COMMON[1]="xxxx"
    CS_COMMON[2]="__REPLACE_CS_COMMON_INFRA2_ADMIN_USERNAME__"
    REPLACE_CS_COMMON[2]="xxxx"
    CS_COMMON[3]="__REPLACE_CS_COMMON_INFRA2_ADMIN_PASSWORD__"
    REPLACE_CS_COMMON[3]="xxxx"

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
    echo >&2 "[INFO] [Step3.1]: made tar archive"

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

    echo >&2 "[INFO]: Complete! ConnectSystem.Config Files has been successfully copied to $PWD"
fi

# # # # # # # # # 

echo >&2 "[INFO] [Step End]: Complete sh for apache! "

# # # # # # # # # 

exec "$@"