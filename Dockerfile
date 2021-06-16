FROM ubuntu:20.04
MAINTAINER jjyoo <magicsoma@hanmail.net>
# Ref : https://github.com/TrafeX/docker-php-nginx

### Install PKG
RUN apt-get update
RUN apt-cache search nginx
RUN apt-get install -y curl \
  nginx \
  php7.4  \
  php7.4-cli  \
  php7.4-ctype \
  php7.4-curl  \
  php7.4-dom \
  php7.4-fpm  \
  php7.4-gd \
  php7.4-intl \
  php7.4-json \
  php7.4-mbstring \
  php7.4-opcache \
  php7.4-phar \
  php7.4-xml \
  php7.4-zip \
  supervisor

RUN rm -f /etc/nginx/conf.d/default.conf
RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symlink so programs depending on `php` still function
#RUN ln -s /usr/bin/php7.4 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7.4/php-fpm.d/www.conf
COPY config/php.ini /etc/php7.4/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nogroup /run 
RUN chown -R nobody.nogroup /var/lib/nginx 
RUN chown -R nobody.nogroup /var/log/nginx

RUN chown -R www-data.www-data /run/php/
RUN chmod -R 777 /run/php/

### php file touch 
RUN touch /var/log/php7.4-fpm.log
RUN chown -R nobody.nogroup /var/log/php7.4-fpm.log

# Add application
WORKDIR /var/www/html
COPY index.php /var/www/html/
#RUN chown -R nobody.nogroup /var/www/html/

# Switch to use a non-root user from here on
#USER nobody

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
