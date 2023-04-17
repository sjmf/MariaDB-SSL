# MariaDB with Self-Signed SSL, under Docker

A collection of scripts to create a docker container for MariaDB using self-signed ssl certificates.

## How it works

Some initial setup has to be done using a `Dockerfile`. Unfortunately, because the Docker container for
MariaDB runs as the `mysql` user (a good security practice), we can't copy in our `ssl.cnf` file at
runtime using the `docker-entrypoint.sh` script, as server config should be owned by root.

Further, we have to patch the `docker-entrypoint.sh` script too, because if we copy `ssl.cnf` before 
runtime, that means that this script will try to connect to an ssl-enabled server without ssl, and
will fail to complete initial setup.

The script `init-ssl.sh` generates self-signed certificates with a sensible set of default values.
Finally, the `create_user.sql` script creates a user with `REQUIRE SSL` turned on.

## How to use it

You can connect to the running server over ssl by specifying `--ssl-ca` on the command line. Otherwise,
the client will not bother to verify the server certificate.

```
mysql -h127.0.0.1 -uroot -proot --ssl-ca=ca.pem
```

You can grab the `ca.pem` from the running server using:

```
docker exec -it mariadbssl cat /etc/mysql/certs/ca.pem > ca.pem
```

## How to run the server

A command line is provided for convenience:

```
docker build --tag="mariadbssl" . && docker run -d -v"certs:/etc/mysql/certs" -v'dbs:/var/lib/mysql' -p"3306:3306/tcp" --name=mariadbssl mariadbssl
```

## Verify that SSL (TLS) is turned on

Try connecting without SSL:

```
mysql -h127.0.0.1 -uroot -proot --ssl-mode=DISABLED
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'arc_iasc'@'172.17.0.1' (using password: YES)
```

Check the server variables when logged in:

```
$ mysql -h127.0.0.1 -uroot -proot --ssl-ca=ca.pem
Welcome to the MySQL monitor.  Commands end with ; or \g.
mysql> SHOW VARIABLES LIKE '%ssl%';
+---------------------+----------------------------------+
| Variable_name       | Value                            |
+---------------------+----------------------------------+
| have_openssl        | YES                              |
| have_ssl            | YES                              |
| ssl_ca              | /etc/mysql/certs/ca-cert.pem     |
| ssl_capath          |                                  |
| ssl_cert            | /etc/mysql/certs/server-cert.pem |
| ssl_cipher          |                                  |
| ssl_crl             |                                  |
| ssl_crlpath         |                                  |
| ssl_key             | /etc/mysql/certs/server-key.pem  |
| version_ssl_library | OpenSSL 3.0.2 15 Mar 2022        |
+---------------------+----------------------------------+
10 rows in set (0.00 sec)

mysql> SHOW SESSION STATUS LIKE 'ssl_version';
+---------------+---------+
| Variable_name | Value   |
+---------------+---------+
| Ssl_version   | TLSv1.3 |
+---------------+---------+
1 row in set (0.01 sec)

mysql> SHOW SESSION STATUS LIKE 'ssl_cipher';
+---------------+------------------------+
| Variable_name | Value                  |
+---------------+------------------------+
| Ssl_cipher    | TLS_AES_256_GCM_SHA384 |
+---------------+------------------------+
1 row in set (0.00 sec)

```
## License

Public domain, 2023.
Hope this repository is useful for you.
