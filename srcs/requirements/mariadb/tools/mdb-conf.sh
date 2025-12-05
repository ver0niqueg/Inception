#!/bin/bash
set -e

# Read secrets if available, otherwise use env variables
if [ -f /run/secrets/db_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

# Fallback to env if secrets not present
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-}
MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}
MYSQL_USER=${MYSQL_USER:-wpuser}

#--------------prepare directories--------------#
# Create required directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 755 /run/mysqld

#--------------mariadb initialization--------------#
# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in background for initial config
echo "Starting MariaDB temporarily..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
pid="$!"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
for i in {30..0}; do
    if mysqladmin ping -S /run/mysqld/mysqld.sock --silent 2>/dev/null; then
        break
    fi
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done

if [ "$i" = 0 ]; then
    echo "MariaDB did not start in time"
    exit 1
fi

echo "MariaDB is ready!"

#--------------mariadb config--------------#
# Only configure if not already done (check if our database exists)
if ! mariadb -S /run/mysqld/mysqld.sock -u root -e "USE \`${MYSQL_DATABASE}\`;" 2>/dev/null; then
    echo "Configuring MariaDB..."
    
    # create database if not exists
    mariadb -S /run/mysqld/mysqld.sock -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    # create user if not exists
    mariadb -S /run/mysqld/mysqld.sock -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    
    # give privileges to user
    mariadb -S /run/mysqld/mysqld.sock -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    
    # Allow root from any host
    mariadb -S /run/mysqld/mysqld.sock -u root -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mariadb -S /run/mysqld/mysqld.sock -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    
    # set root password for localhost
    mariadb -S /run/mysqld/mysqld.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    
    # flush privileges to apply changes
    mariadb -S /run/mysqld/mysqld.sock -u root -e "FLUSH PRIVILEGES;"
    
    echo "MariaDB configured successfully!"
else
    echo "MariaDB already configured, skipping initialization"
fi

#--------------mariadb restart---------------#
# Stop the temporary MariaDB process
echo "Stopping temporary MariaDB process..."
kill "$pid"
wait "$pid" 2>/dev/null || true

# Start MariaDB in the foreground to keep the container running
echo "Starting MariaDB in production mode..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306
