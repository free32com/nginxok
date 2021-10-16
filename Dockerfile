FROM ubuntu:20.04

RUN apt-get update
RUN apt-cache search nginx
RUN apt-get install -y curl \
  nginx \
  supervisor

RUN rm -f /etc/nginx/conf.d/default.conf
RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY config/nginx.conf /etc/nginx/nginx.conf

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/html

RUN chown -R nobody.nogroup /run 
RUN chown -R nobody.nogroup /var/lib/nginx 
RUN chown -R nobody.nogroup /var/log/nginx

WORKDIR /var/www/html
COPY index.php /var/www/html/

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
