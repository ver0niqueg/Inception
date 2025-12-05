#!/bin/bash
set -e

# Read secrets if available, otherwise use env variables
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

#--------------prepare directories--------------#
# Create required directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

#--------------mariadb initialization--------------#
# Check if database is already initialized
echo "Initializing MariaDB data directory..."
mysql--user=mysql --datadir=/var/lib/mysql &
sleep 5

# Start MariaDB in background for initial config
echo "Starting MariaDB temporarily..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

#--------------mariadb config--------------#
# Only configure if not already done (check if our database exists)
    echo "Configuring MariaDB..."
    
    # create database if not exists
    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_ROOT_PASSWORD}\`;"
    
    # create user if not exists
    mariadb -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_ROOT_PASSWORD}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    
    # give privileges to user
    mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_ROOT_PASSWORD}\`.* TO \`${MYSQL_USER}\`@'%';"
    
    # set root password
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    
    # flush privileges to apply changes
    mariadb -u root -p"$(MYSQL_ROOT_PASSWORD)" -e "FLUSH PRIVILEGES;"
    
    echo "MariaDB configured successfully!"
else
    echo "MariaDB already configured, skipping initialization"
fi

#--------------mariadb restart---------------#
# Stop the temporary MariaDB process
mysqladmin -u root =p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB in the foreground to keep the container running
echo "Starting MariaDB in production mode..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306
