#!/bin/bash
set -e

echo "=== Starting MariaDB setup ==="

# Create run directory for MariaDB
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "Configuring MariaDB with bootstrap mode..."
    # Use bootstrap mode to configure database
    cat << EOF | mysqld --user=mysql --bootstrap
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "✓ MariaDB configured successfully!"
else
    echo "MariaDB already initialized, skipping setup..."
fi

# Start MariaDB
echo "Starting MariaDB server..."
exec mysqld --user=mysql --console