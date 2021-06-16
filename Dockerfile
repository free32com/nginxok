FROM ubuntu:20.04
MAINTAINER jjyoo <magicsoma@hanmail.net>
# Ref : https://github.com/TrafeX/docker-php-nginx

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

COPY config/nginx.conf /etc/nginx/nginx.conf

COPY config/fpm-pool.conf /etc/php7.4/php-fpm.d/www.conf
COPY config/php.ini /etc/php7.4/conf.d/custom.ini

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/html

RUN chown -R nobody.nogroup /run 
RUN chown -R nobody.nogroup /var/lib/nginx 
RUN chown -R nobody.nogroup /var/log/nginx

RUN chown -R www-data.www-data /run/php/
RUN chmod -R 777 /run/php/

RUN touch /var/log/php7.4-fpm.log
RUN chown -R nobody.nogroup /var/log/php7.4-fpm.log

WORKDIR /var/www/html
COPY index.php /var/www/html/

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
