#!/bin/bash

# here we will check github repo for new commits
# and will update php code with new code

set -x -e

# Folloing variables must be defined in your secret
# variables, like Environment variables of the GitLab.
# DEPLOY_DIR="/var/www/mysite"
# DEPLOY_BRANCH="master"
# GIT_SOURCE="https://gitlab.com/<yourname>/<yoursite>.git"

# MAX_RELEASES=$1
# DEPLOY_DIR=$2
# DEPLOY_BRANCH=$3
# GIT_SOURCE=$4

GIT_LOGIN="xxxxx"
GIT_TOKEN="xxxxx"

MAX_RELEASES=3
DEPLOY_DIR="/var/www/html"
DEPLOY_BRANCH="main"
GIT_SOURCE="git@github.com:xxxxxx/texas2021.git"

CI_COLOR="\033[0;32m"
NO_COLOR="\033[0m"

GIT_DIR="$DEPLOY_DIR/repo"
RELEASES_DIR="$DEPLOY_DIR/releases"
RAW_DIR="$DEPLOY_DIR/raw"

print_title() {
  echo "";
  print_row "$@";
}

print_row() {
  echo -e "${CI_COLOR}$@${NO_COLOR}";
}


# Checking begin block if long beginning
if [ ! -f "/var/www/ctab/begin.txt" ]; then
    exit 1
fi

B_BLOCK_STATUS=$(cat /var/www/ctab/begin.txt)
if [ $B_BLOCK_STATUS = "1" ]; then
    print_title "begin block status == 1! its BLOCKED. Exiting ..."
    exit 1
else
    print_title "begin block status !== 1, and its okay..."
fi

# Checking block if long github updates
print_title "Check if github update is already working now"
if [ ! -f "/var/www/ctab/block.txt" ]; then
    touch "/var/www/ctab/block.txt"
fi

BLOCK_STATUS=$(cat /var/www/ctab/block.txt)
if [ $BLOCK_STATUS = "1" ]; then
    print_title "block status == 1! its BLOCKED. Exiting ..."
    exit 1
else
    print_title "block status !== 1, so lets begin our work ..."
    echo "1" > /var/www/ctab/block.txt
fi

# Adding login-password for github
# print_title "Adding login to .netrc"
# mkdir -p "/home/root/"
# touch "/home/root/.netrc"
# echo "machine github.com login $GIT_LOGIN password $GIT_TOKEN" > /home/root/.netrc


# Start deployment process.

print_title "Creating regular directories ..."
mkdir -p "$DEPLOY_DIR"
mkdir -p "$GIT_DIR"
mkdir -p "$RELEASES_DIR"
mkdir -p "$RAW_DIR"
echo "Done"

print_title "Checking that we have git in \"$GIT_DIR\" folder"
cd "$GIT_DIR"
if [ ! $(git status 2>/dev/null) ]; then
    echo "Cloning repository ..."
    mkdir -p "/root/.ssh/"
    echo "-----BEGIN OPENSSH PRIVATE KEY-----
b3lxxxxg==
-----END OPENSSH PRIVATE KEY-----" > /root/.ssh/id_rsa
    chmod 600 "/root/.ssh/id_rsa"
    echo "IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

    touch "/root/.ssh/known_hosts"
    ssh-keyscan "github.com" >> /root/.ssh/known_hosts
    cd "../" && rm -rf "$GIT_DIR" && git clone $GIT_SOURCE $GIT_DIR 
    cd "$GIT_DIR"
    echo "Done"
fi

# Check that repo has new commits 
print_title "Check that repo has new commits "
cd "$GIT_DIR"
git remote update
B_UPSTREAM=${1:-'@{u}'}
B_LOCAL=$(git rev-parse @)
B_REMOTE=$(git rev-parse "$B_UPSTREAM")
B_BASE=$(git merge-base @ "$B_UPSTREAM")

if [ $B_LOCAL = $B_REMOTE ]; then
    # Up-to-date
    # No changes
    print_title "There are no any new commits in repo! Exiting..."
    # Сhanging block status to zero
    echo "0" > /var/www/ctab/block.txt
    exit 1
elif [ $B_LOCAL = $B_BASE ]; then
    # Need to pull
    # Changes
    print_title "Git repo have new commits!"
elif [ $B_REMOTE = $B_BASE ]; then
    print_title "There are local commits that needs to be pushed! ?!?"
    git reset --hard
fi

print_title "Updating repo to last version"
git fetch --all
# git reset --hard "origin/$DEPLOY_BRANCH"
git reset --hard
# git pull origin $DEPLOY_BRANCH
git pull
echo "Done"

COMMIT=$(git log -n1 --abbrev-commit|grep ^commit|awk '{print $2}')
TIMESTAMP=$(date +%Y.%m.%d_%H-%M-%S)
RELEASE="$TIMESTAMP.$COMMIT"
RELEASE_DIR="$RELEASES_DIR/$RELEASE"


print_title "Create directory for the new release \"$RELEASE\""
mkdir -p "$RELEASE_DIR" && echo "Done"

print_title "Deploy the release \"$RELEASE\""
rsync -a --stats --inplace "$GIT_DIR/" "$RELEASE_DIR" --exclude=".git" --exclude="scripts" --exclude="gitlab-ci.yml" && echo "Done"

print_title "Copy raw files"
# chmod 755 -R "$RELEASE_DIR" # This might be helpful here.
rsync -al --force --stats "$RAW_DIR/" "$RELEASE_DIR" && echo "Done"


cd $RELEASES_DIR

chown -R www-data:www-data "$RELEASE_DIR"
/usr/bin/find "$RELEASE_DIR" -type d -exec chmod 755 {} +;
/usr/bin/find "$RELEASE_DIR" -type f -exec chmod 644 {} +;

# Adding some more stuff for working yii framework
touch "$RELEASE_DIR/911.php"
echo "<?php echo('nanohealth'); ?>" > "$RELEASE_DIR/911.php"

# ========
# Changing variables in config files main.php or main-local.php
# API VARIABLES
CS_API[0]="__REPLACE_CS_API_COOKIE__"
REPLACE_CS_API[0]="xxxxxx"

# BACKEND VARIABLES
CS_BACKEND[0]="__REPLACE_CS_BACKEND_COOKIE__"
REPLACE_CS_BACKEND[0]="xxxxx"

# COMMON VARIABLES
CS_COMMON[0]="__REPLACE_CS_COMMON_INFRA1_ADMIN_USERNAME__"
REPLACE_CS_COMMON[0]="xxxx"
CS_COMMON[1]="__REPLACE_CS_COMMON_INFRA1_ADMIN_PASSWORD__"
REPLACE_CS_COMMON[1]="xxxxx"
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
    if [ -f "$RELEASE_DIR/api/config/main.php" ]; then
        sed -i 's/'"${CS_API[$i]}"'/'"${REPLACE_CS_API[$i]}"'/g' $RELEASE_DIR/api/config/main.php
    fi
done

arraylength2=${#CS_BACKEND[@]}
for (( i=0; i<${arraylength2}; i++ )); do
    echo >&2 "[INFO]: backend cycle, $i"
    if [ -f "$RELEASE_DIR/backend/config/main.php" ]; then
        sed -i 's/'"${CS_BACKEND[$i]}"'/'"${REPLACE_CS_BACKEND[$i]}"'/g' $RELEASE_DIR/backend/config/main.php
    fi
done

arraylength3=${#CS_COMMON[@]}
for (( i=0; i<${arraylength3}; i++ )); do
    echo >&2 "[INFO]: common cycle, $i"
    if [ -f "$RELEASE_DIR/common/config/main.php" ]; then
        sed -i 's/'"${CS_COMMON[$i]}"'/'"${REPLACE_CS_COMMON[$i]}"'/g' $RELEASE_DIR/common/config/main.php
    fi
done

arraylength4=${#CS_FRONTEND_MAIN[@]}
for (( i=0; i<${arraylength4}; i++ )); do
    echo >&2 "[INFO]: frontend cycle1, $i"
    if [ -f "$RELEASE_DIR/frontend/config/main.php" ]; then
        sed -i 's/'"${CS_FRONTEND_MAIN[$i]}"'/'"${REPLACE_CS_FRONTEND_MAIN[$i]}"'/g' $RELEASE_DIR/frontend/config/main.php
    fi
done

arraylength5=${#CS_FRONTEND_MAIN_LOCAL[@]}
for (( i=0; i<${arraylength5}; i++ )); do
    echo >&2 "[INFO]: frontend cycle2, $i"
    if [ -f "$RELEASE_DIR/frontend/config/main-local.php" ]; then
        sed -i 's/'"${CS_FRONTEND_MAIN_LOCAL[$i]}"'/'"${REPLACE_CS_FRONTEND_MAIN_LOCAL[$i]}"'/g' $RELEASE_DIR/frontend/config/main-local.php
    fi
done

arraylength6=${#CS_COMMON_BOOTSTRAP[@]}
for (( i=0; i<${arraylength6}; i++ )); do
    echo >&2 "[INFO]: common-boostrap cycle, $i"
    if [ -f "$RELEASE_DIR/common/config/bootstrap.php" ]; then
        sed -i 's/'"${CS_COMMON_BOOTSTRAP[$i]}"'/'"${REPLACE_CS_COMMON_BOOTSTRAP[$i]}"'/g' $RELEASE_DIR/common/config/bootstrap.php
    fi
done

# end replacing
# ========

cp "$RELEASE_DIR/.htaccess-aws" "$RELEASE_DIR/.htaccess"

# for testing 1 coutnaienr
rm -rf "$RELEASE_DIR/api/runtime"
rm -rf "$RELEASE_DIR/console/runtime"
rm -rf "$RELEASE_DIR/backend/runtime"
rm -rf "$RELEASE_DIR/frontend/runtime"

rm -rf "$RELEASE_DIR/frontend/web/assets"
rm -rf "$RELEASE_DIR/backend/web/assets"

mkdir -p "$RELEASE_DIR/api/runtime"
mkdir -p "$RELEASE_DIR/console/runtime"
mkdir -p "$RELEASE_DIR/backend/runtime"
mkdir -p "$RELEASE_DIR/frontend/runtime"

mkdir -p "$RELEASE_DIR/frontend/web/assets"
mkdir -p "$RELEASE_DIR/backend/web/assets"
# end 1 container

chown -R www-data:www-data "$RELEASE_DIR/api/runtime"
chown -R www-data:www-data "$RELEASE_DIR/console/runtime"
chown -R www-data:www-data "$RELEASE_DIR/backend/runtime"
chown -R www-data:www-data "$RELEASE_DIR/frontend/runtime"

chown -R www-data:www-data "$RELEASE_DIR/frontend/web/assets"
chown -R www-data:www-data "$RELEASE_DIR/backend/web/assets"

# make all www-data
find $RELEASE_DIR -type d -exec chmod 755 {}  +
find $RELEASE_DIR  -type f -exec chmod 644 {} +
# chown -R www-data:www-data "/var/www/html/releases/001"
chown -R www-data:www-data "$RELEASE_DIR"


if [ -f "$RELEASE_DIR/common/modules/Autoprefixer/js/node_modules/postcss-cli/bin/postcss" ]; then
    chmod +x "$RELEASE_DIR/common/modules/Autoprefixer/js/node_modules/postcss-cli/bin/postcss"
fi

# Сhanging symlink to current release!
print_title "Create symlink to the release \"$RELEASE\""
ln -sfn "$RELEASE_DIR" "$DEPLOY_DIR/current" && echo "Done"


# Deleting old releases
cd $RELEASES_DIR
if [ $(ls -l | grep -c ^d) -gt $MAX_RELEASES ] ; then
    print_title "Delete deprecated versions"
    while [ $(ls -l | grep -c ^d) -gt $MAX_RELEASES ]
    do
        DEPRECATED_RELEASE=$(ls -r | tail -n 1)

        if [ $DEPRECATED_RELEASE = "001" ]; then
            echo "Version \"$DEPRECATED_RELEASE\" is 001 so not action needed"
            MAX_RELEASES=$(($MAX_RELEASES + 1))
        else
            chmod 755 -R ./$DEPRECATED_RELEASE
            rm -rf ./$DEPRECATED_RELEASE
            echo "Version \"$DEPRECATED_RELEASE\" has been deleted"
        fi

        # rm -rf ./$DEPRECATED_RELEASE
        # echo "Version \"$DEPRECATED_RELEASE\" has been deleted"
    done
    echo "Done"
else
    print_title "Deprecated versions not found"
fi


# Сhanging block status to zero
echo "0" > /var/www/ctab/block.txt

# and restarting php 
print_title "Restarting php"
service php7.4-fpm restart

print_title "The deployment completed successfully"