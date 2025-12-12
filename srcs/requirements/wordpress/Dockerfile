FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y curl php8.2-fpm php8.2-mysql mariadb-client

RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

COPY ./tools/wp_conf.sh /

RUN chmod +x wp_conf.sh

ENTRYPOINT ["./wp_conf.sh"]