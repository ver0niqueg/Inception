# MariaDB is an open-source relational database management system

# pull base image
FROM debian:bookworm

# update and install required packages in one layer
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server netcat-traditional && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# copy file from host to container
COPY ./tools/mdb-conf.sh /mdb-conf.sh
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#set permissions to the file
RUN chmod +x /mdb-conf.sh

#define entrypoint command to run when the container starts
ENTRYPOINT ["/mdb-conf.sh"]