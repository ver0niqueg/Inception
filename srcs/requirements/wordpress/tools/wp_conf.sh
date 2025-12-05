#!/bin/bash
set -e

# Read secrets if available, otherwise use env variables
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_user_password ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi

# Fallback to env if secrets not present
MYSQL_PASSWORD=${MYSQL_PASSWORD:-}
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-}
WP_USER_PASSWORD=${WP_USER_PASSWORD:-}

echo "Waiting for MariaDB to be ready..."
# Wait for MariaDB to be available
for i in {1..60}; do
    if mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &>/dev/null; then
        echo "MariaDB is ready!"
        break
    fi
    echo "Waiting for database... ($i/60)"
    sleep 2
done

# Final check
if ! mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &>/dev/null; then
    echo "ERROR: Could not connect to database after 120 seconds"
    echo "Credentials: user=$MYSQL_USER db=$MYSQL_DATABASE host=mariadb"
    exit 1
fi

#--------------------wp installation--------------------#
# wp-cli installation
if [ ! -f /usr/local/bin/wp ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# go to wordpress directory
cd /var/www/wordpress

# download wordpress core files if not already downloaded
if [ ! -f wp-config-sample.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

# create wp-config.php file with database details if not exists
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create --dbhost=mariadb:3306 --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
fi

# install wordpress if not already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
    
    # create a new user
    echo "Creating WordPress user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" --user_pass="$WP_USER_PASSWORD" --role=editor --allow-root || true
    
    echo "WordPress installation complete!"
fi

# Set correct permissions AFTER installation
echo "Setting correct permissions..."
find /var/www/wordpress -type d -exec chmod 755 {} \;
find /var/www/wordpress -type f -exec chmod 644 {} \;
chown -R www-data:www-data /var/www/wordpress

echo "WordPress setup complete! Starting PHP-FPM..."

#--------------------wp config--------------------#
# Configure PHP-FPM to listen on port 9000
echo "Configuring PHP-FPM..."
sed -i 's/listen = .*/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf
# Ensure PHP-FPM listens on all interfaces
sed -i 's/;listen.owner/listen.owner/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/;listen.group/listen.group/' /etc/php/8.2/fpm/pool.d/www.conf

# create a directory for php-fpm
mkdir -p /run/php

# start php-fpm service in the foreground to keep the container running
echo "Starting PHP-FPM..."
/usr/sbin/php-fpm8.2 -F
