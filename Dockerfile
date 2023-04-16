FROM mariadb:latest

WORKDIR /etc/mysql/
RUN mkdir certs && \
   chown mysql:mysql /etc/mysql/certs && \
   chmod 700 /etc/mysql/certs

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ssl.cnf              /etc/mysql/conf.d/

COPY init-ssl.sh          /docker-entrypoint-initdb.d/
COPY speak-ca.sh          /docker-entrypoint-initdb.d/
COPY iasc.sql             /docker-entrypoint-initdb.d/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh /docker-entrypoint-initdb.d/init-ssl.sh

RUN  bash -c /docker-entrypoint-initdb.d/init-ssl.sh

ENV MARIADB_ROOT_PASSWORD=root
ENV MARIADB_MYSQL_LOCALHOST_USER=mysql@localhost
ENV MARIADB_DATABASE=test

