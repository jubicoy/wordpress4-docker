#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /workdir/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

# Copy configuration files
if [ ! -f /var/www/wordpress/wp-content/wp-config.php ]; then
    cp -f /workdir/wp-config.php /var/www/wordpress/wp-content/wp-config.php
    sed -i "s/database_name_here/${MYSQL_DATABASE}/g" /var/www/wordpress/wp-content/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/g" /var/www/wordpress/wp-content/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/g" /var/www/wordpress/wp-content/wp-config.php

    # Move default plugins and themes back to volume
    cp -arf /tmp/plugins /var/www/wordpress/wp-content/
    cp -arf /tmp/themes /var/www/wordpress/wp-content/
    cp -arf /tmp/index.php /var/www/wordpress/wp-content/
fi

exec "/usr/bin/supervisord"
