FROM jubicoy/nginx-php:php7
ENV WP_VERSION 4.8

# Additional web server requirements
RUN apt-get update && apt-get -y install \
    php7.0-fpm php7.0-common php7.0-cgi \
    php7.0-mysql php-apcu pwgen python-setuptools \
    curl git unzip php7.0-curl php7.0-gd php7.0-intl \
    php-pear php-imagick php7.0-imap php7.0-mcrypt \
    php-memcache php7.0-pspell php7.0-soap \
    php7.0-recode php7.0-sqlite php7.0-tidy php7.0-xmlrpc \
    php7.0-xsl php7.0-mbstring gzip apache2-utils

#RUN apt-get install -y apache2-utils

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -k https://wordpress.org/wordpress-$WP_VERSION.tar.gz | tar zx -C /var/www/

# Move default plugins and themes to a safe place
RUN mv  /var/www/wordpress/wp-content/plugins /tmp/ && \
    mv  /var/www/wordpress/wp-content/themes /tmp/ && \
    mv  /var/www/wordpress/wp-content/index.php /tmp/index.php

RUN chmod -R 777 /tmp/plugins && \
    chmod -R 777 /tmp/themes

# Add configuration files
ADD config/default.conf /workdir/default.conf
ADD config/wp-config.php /workdir/wp-config.php
ADD entrypoint.sh /workdir/entrypoint.sh
RUN rm -f /etc/nginx/conf.d/default.conf && ln -s /var/www/wordpress/wp-content/conf/default.conf /etc/nginx/conf.d/default.conf

# Composer for Sabre installation
ENV COMPOSER_VERSION 1.0.0-alpha11
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION}

# WebDAV configuration
RUN mkdir -p /var/www/webdav && mkdir -p /var/www/webdav/locks && chmod -R 777 /var/www/webdav/locks
ADD config/webdav.conf /etc/nginx/conf.d/webdav.conf
ADD sabre/index.php /var/www/webdav/index.php

# Sabre with composer
RUN cd /var/www/webdav && composer require sabre/dav ~3.1.0 && composer update sabre/dav && cd

RUN ln -s /var/www/wordpress/wp-content/wp-config.php /var/www/wordpress/wp-config.php

RUN chown -R 104:0 /var/www && chmod -R g+rw /var/www && \
    chmod a+x /workdir/entrypoint.sh && chmod g+rw /workdir

# PHP max upload size
RUN sed -i '/upload_max_filesize/c\upload_max_filesize = 250M' /etc/php/7.0/fpm/php.ini
RUN sed -i '/post_max_size/c\post_max_size = 250M' /etc/php/7.0/fpm/php.ini

VOLUME ["/var/www/wordpress/wp-content"]

EXPOSE 5000
EXPOSE 5005

USER 104
