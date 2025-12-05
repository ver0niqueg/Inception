#!/bin/bash

# Create socket directory
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

#--------------mariadb start--------------#
# start mariadb in background for initial config
mysqld --user=mysql --datadir=/var/lib/mysql &
sleep 5 # wait for mariadb to start

#--------------mariadb config--------------#
# create mariadb if not exists
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

# create user if not exists
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# give privileges to user
mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"

# flush privileges to apply changes
mariadb -e "FLUSH PRIVILEGES;"

#--------------mariadb restart---------------#
# shutdown mariadb to restart with new config
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# restart mariadb with new config in the foreground to keep the container running
mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'