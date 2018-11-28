FROM jubicoy/nginx-php:php7.2

# Additional web server requirements
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2-utils \
    curl \
    git \
    gzip \
    php-apcu \
    php-imagick \
    php-memcache \
    php-pear \
    php7.2-curl \
    php7.2-cgi \
    php7.2-gd \
    php7.2-imap \
    php7.2-intl \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-pspell \
    php7.2-recode \
    php7.2-soap \
    php7.2-sqlite \
    php7.2-tidy \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-zip \
    pwgen \
    python-setuptools \
    unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV WP_IMAGE_COMMIT ${WP_IMAGE_COMMIT:-dev}
ENV COMPOSER_VERSION 1.7.3
ENV SABRE_VERSION ~3.2.0

# * Install Wordpress and move default plugins and themes to a safe place
# * Install Composer
# * Install Sabre
RUN curl -k "https://wordpress.org/wordpress-${WP_VERSION:-4.9.4}.tar.gz" | tar zx -C /var/www/ \
  && mv /var/www/wordpress/wp-content/plugins /tmp/ \
  && mv /var/www/wordpress/wp-content/themes /tmp/ \
  && mv /var/www/wordpress/wp-content/index.php /tmp/index.php \
  && chmod -R 777 /tmp/plugins \
  && chmod -R 777 /tmp/themes \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version="${COMPOSER_VERSION}" \
  &&  mkdir -p /var/www/webdav/locks \
  && chmod -R 777 /var/www/webdav/locks \
  && cd /var/www/webdav \
  && composer require sabre/dav "${SABRE_VERSION}" \
  && composer update sabre/dav \
  && cd

COPY root /

# Finalize WP config
# Link configuration files
RUN rm -f /etc/nginx/conf.d/default.conf \
  && ln -s /var/www/wordpress/wp-content/conf/default.conf /etc/nginx/conf.d/default.conf \
  && mv /etc/php/7.2/fpm/php.ini /tmp/php.ini \
  && ln -s /var/www/wordpress/wp-content/wp-config.php /var/www/wordpress/wp-config.php \
  && ln -s /var/www/wordpress/wp-content/conf/php.ini /etc/php/7.2/fpm/php.ini \
  && chown -R 104:0 /var/www \
  && chmod -R g+rw /var/www \
  && chmod g+rw /workdir \
  && chmod -R g+rw /var/lib/nginx \
  && chmod a+rwx /var/lib/nginx \
  && sed -i '/upload_max_filesize/c\upload_max_filesize = 250M' /tmp/php.ini \
  && sed -i '/post_max_size/c\post_max_size = 250M' /tmp/php.ini

VOLUME ["/var/www/wordpress/wp-content"]

EXPOSE 5000
EXPOSE 5005

USER 104

CMD ["/opt/bin/start-cmd"]
