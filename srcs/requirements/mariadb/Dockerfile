FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server netcat-traditional && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./tools/mdb-conf.sh /mdb-conf.sh
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /mdb-conf.sh

ENTRYPOINT ["/mdb-conf.sh"]