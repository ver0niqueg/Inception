#!/bin/bash

set -euo pipefail

# Read secrets if present
if [ -f /run/secrets/db_password ]; then
	export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/db_root_password ]; then
	export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
	export WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi

# Wait until the database is reachable
while ! mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" ${MYSQL_PASSWORD:+-p"${MYSQL_PASSWORD}"} --silent; do
	sleep 1
done

# Si le fichier wp-config.php n'existe pas, WordPress n'est pas encore installé
if [ ! -f "/var/www/html/wp-config.php" ]; then
	wp core download --allow-root # Télécharge les fichiers de base de WordPress

# Crée le fichier wp-config.php avec les paramètres de connexion à la base de données
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD:-}" \
		--dbhost="mariadb" \
		--allow-root

# Installe WordPress (remplit la base de données, crée le site)
	wp core install \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

# Crée un utilisateur supplémentaire avec le rôle d'éditeur	
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--role=editor \
		--user_pass="${WP_USER_PASSWORD:-userpass}" \
		--allow-root
fi

chown -R www-data:www-data /var/www/html # Donne les droits à l'utilisateur www-data
chmod -R 755 /var/www/html

# Démarre PHP-FPM en mode foreground, remplaçant le processus actuel
exec php-fpm8.2 -F
