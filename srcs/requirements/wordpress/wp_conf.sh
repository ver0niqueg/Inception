#!/bin/bash

#--------------------wp installation--------------------#
# wp-cli installation
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# wp-cli permission
chmod +x wp-cli.phar
# wp-cli move to bin
mv wp-cli.phar /usr/local/bin/wp

# go to wordpress directory
cd /var/www/wordpress
# give permission to wordpress directory
chmod -R 755 /var/www/wordpress
# change owner of wordpress directory to www-data
chown -R www-data:www-data /var/www/wordpress
#--------------------wp installation--------------------#

# download wordpress core files
wp core download --allow-root
# create wp-config.php file with database details
wp config create --dbhost=mariadb:3306 --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
# install wordpress with the giver title, admin username, password and email
wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root
# create a new user with the given username, email, password and role
wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=editor --allow-root

#--------------------wp config--------------------#
# change listen port from unix socket to 9000
sed -i 's@/run/php/php8.2-fpm.sock@9000@' /etc/php/8.2/fpm/pool.d/www.conf
# create a directory for php-fpm
mkdir -p /run/php
# start php-fpm service in the foreground to keep the container running
/usr/sbin/php-fpm8.2 -F