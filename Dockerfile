FROM alpine:3.8

# Environments
ENV PHP_PACKEGES php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl php7-zlib php7-xml php7-phar php7-intl \
    php7-dom php7-xmlreader php7-ctype php7-mbstring php7-gd php7-pdo php7-pdo_mysql php7-sockets php7-zip php7-imap \
    php7-mcrypt php7-session php7-cgi php7-bz2 php7-bcmath php7-calendar php7-exif php7-gettext php7-ldap php7-yaml \
    php7-soap php7-apcu php7-ssh2 php7-redis php7-xmlwriter php7-tokenizer php7-posix

ENV MAIN_PACKAGES nginx supervisor curl mysql-client

ENV ADDITIONAL_PACKAGES nano git

ENV TIMEZONE Europe/Kiev

# Install packages
RUN apk update \
    && apk upgrade \
    && apk add $PHP_PACKEGES \
    && apk add $MAIN_PACKAGES \
    && apk add $ADDITIONAL_PACKAGES \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo "$TIMEZONE" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

# Configure
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY config/php/php-fpm.conf /etc/php7/php-fpm.d/custom.php-fpm.conf
COPY config/supervisord.ini /etc/supervisor.d/nginx-supervisor.ini
RUN mkdir -p /usr/share/nginx/html /var/log/supervisor \
    && echo "Index page" >> /usr/share/nginx/html/index.html

# Additional settings
RUN mkdir -p /var/www
WORKDIR /var/www
VOLUME /var/www

EXPOSE 80
EXPOSE 9000
CMD ["/usr/bin/supervisord"]