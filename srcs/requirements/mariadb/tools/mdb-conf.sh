#!/bin/bash

# Read secrets if available, otherwise use env variables
if [ -f /run/secrets/db_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

#--------------mariadb start--------------#
# start mariadb in background for initial config
mysqld --user=mysql --datadir=/var/lib/mysql &
sleep 5 # wait for mariadb to start

#--------------mariadb config--------------#
# create mariadb if not exists
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# create user if not exists
mariadb -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# give privileges to user
mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

# set root password
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# flush privileges to apply changes
mariadb -u root -e "FLUSH PRIVILEGES;"

#--------------mariadb restart---------------#
# shutdown mariadb to restart with new config
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# restart mariadb with new config in the foreground to keep the container running
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306
