FROM wordpress:php8.2-fpm

RUN apt-get update && apt-get install -y \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Modifier la config php-fpm au bon endroit
RUN sed -i 's|listen =.*|listen = 9000|g' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm"]