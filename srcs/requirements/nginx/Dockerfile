# NGINX is a high performance, open-source web server and reverse proxy server software

# pull base image
FROM debian:bookworm

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# install the required packages
RUN apt-get install -y nginx openssl

# create the ssl directory
RUN mkdir -p /etc/nginx/ssl

# generate the ssl certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout \
	/etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=vgalmich.42.fr/UID=vgalmich"

# copy the nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# create the wordpress directory
RUN mkdir -p /var/www/wordpress

# change the owner of the wordpress directory to www-data
RUN chown -R www-data:www-data /var/www/wordpress

# define the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]