#!/bin/bash
set -e

echo "=== Starting WordPress setup ==="

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" -e "SELECT 1;" &>/dev/null; then
        echo "✓ MariaDB is ready!"
        break
    fi
    echo "Waiting for database... ($i/30)"
    sleep 2
done

#--------------------wp installation--------------------#
# wp-cli installation
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# go to wordpress directory
cd /var/www/wordpress

# give permission to wordpress directory
echo "Setting permissions..."
chmod -R 755 /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress

# download wordpress core files
echo "Downloading WordPress..."
wp core download --allow-root

# create wp-config.php file with database details
echo "Creating wp-config.php..."
echo "DB: $MYSQL_DB, User: $MYSQL_USER, Host: mariadb:3306"
wp config create --dbhost=mariadb:3306 --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root

# Verify wp-config.php was created
if [ -f wp-config.php ]; then
    echo "✓ wp-config.php created successfully!"
else
    echo "✗ ERROR: wp-config.php was not created!"
    exit 1
fi

# install wordpress
echo "Installing WordPress..."
wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root

# create a new user
echo "Creating WordPress user..."
wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=editor --allow-root || echo "User might already exist"

echo "✓ WordPress setup complete!"

#--------------------wp config--------------------#
# change listen port from unix socket to 9000
sed -i 's@/run/php/php8.2-fpm.sock@9000@' /etc/php/8.2/fpm/pool.d/www.conf
# create a directory for php-fpm
mkdir -p /run/php
# start php-fpm service in the foreground to keep the container running
/usr/sbin/php-fpm8.2 -F