# wordpress is an open-source content management system used to build and manage websites without needing to code

# pull the base image
FROM debian:bookworm

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# install the required packages
RUN apt-get install -y curl php8.2-fpm php8.2-mysql mariadb-client

# create the wordpress directory
RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

#copy the wordpress configuration script to the root directory in the container
COPY ./tools/wp_conf.sh /

# change the permission of the script to make it executable
RUN chmod +x /wp_conf.sh

# define the entrypoint command to run when the container starts
ENTRYPOINT ["/wp_conf.sh"]