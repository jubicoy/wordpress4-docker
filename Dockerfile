FROM jubicoy/nginx-php:latest
ENV WP_VERSION 4.3.1

# Additional web server requirements
RUN apt-get update && apt-get install -y \
    php5-mysql php-apc pwgen python-setuptools \
    curl git unzip php5-curl php5-gd php5-intl \
    php-pear php5-imagick php5-imap php5-mcrypt \
    php5-memcache php5-ming php5-ps php5-pspell \
    php5-recode php5-sqlite php5-tidy php5-xmlrpc \
    php5-xsl gzip

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -k https://wordpress.org/wordpress-$WP_VERSION.tar.gz | tar zx -C /var/www/

# Move default plugins and themes to a safe place
RUN mv  /var/www/wordpress/wp-content/plugins /tmp/ && \
    mv  /var/www/wordpress/wp-content/themes /tmp/ && \
    mv  /var/www/wordpress/wp-content/index.php /tmp/index.php

RUN chmod -R 777 /tmp/plugins && \
    chmod -R 777 /tmp/themes && 

# Add configuration files
ADD config/default.conf /etc/nginx/conf.d/default.conf
ADD config/wp-config.php /workdir/wp-config.php
ADD entrypoint.sh /workdir/entrypoint.sh

RUN ln -s /var/www/wordpress/wp-content/wp-config.php /var/www/wordpress/wp-config.php

RUN chown -R 104:0 /var/www && chmod -R g+rw /var/www && \
    chmod a+x /workdir/entrypoint.sh && chmod g+rw /workdir

VOLUME ["/var/www/wordpress/wp-content"]

USER 104
