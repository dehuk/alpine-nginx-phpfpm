FROM alpine:3.8

# Environments
ENV PHP_PACKEGES php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl php7-zlib php7-xml php7-phar php7-intl \
    php7-dom php7-xmlreader php7-ctype php7-mbstring php7-gd php7-pdo php7-pdo_mysql php7-sockets php7-zip php7-imap \
    php7-mcrypt

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
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/php.ini /etc/php7/php.ini
COPY config/php-fpm.conf /etc/php7/php-fpm.d/php-fpm.conf
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /etc/nginx/sites-enabled

# Additional settings
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]