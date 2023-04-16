FROM mariadb:latest

RUN apt-get update && \
    apt-get install patch && \
    apt-get clean

# Patch docker-entrypoint.sh to enable SSL in startup script
WORKDIR /usr/local/bin
COPY docker-entrypoint.sh.patch .
RUN patch -l --ignore-whitespace < docker-entrypoint.sh.patch

# Create certificates directory
WORKDIR /etc/mysql/
RUN mkdir certs && \
   chown mysql:mysql /etc/mysql/certs && \
   chmod 700 /etc/mysql/certs

# Copy configuration files
COPY ssl.cnf              /etc/mysql/conf.d/
COPY init-ssl.sh          /docker-entrypoint-initdb.d/
COPY speak-ca.sh          /docker-entrypoint-initdb.d/
COPY iasc.sql             /docker-entrypoint-initdb.d/

# Alas we have to run this first as MariaDB tests the server before running it
RUN  bash -c /docker-entrypoint-initdb.d/init-ssl.sh

# Useful environment vars
ENV MARIADB_ROOT_PASSWORD=root
ENV MARIADB_MYSQL_LOCALHOST_USER=mysql@localhost
ENV MARIADB_DATABASE=test

