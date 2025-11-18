# stable version
FROM debian:bookworm

# avoid interactive prompt
ENV DEBIAN_FRONTEND=noninteractive

# MAJ list & packages
RUN apt-get update -y && apt-get upgrade -y
    apt-get install mariaddb-server -y

#  copy the config files in the container filesystem
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

# create MySQL runtime directory
RUN mkdir -p /run/mysql && chown -R mysql:mysql /run/mysqld

CMD ["/usr/local/bin/script.sh"]