# MariaDB with Self-Signed SSL

A collection of scripts to create a docker container for MariaDB using self-signed ssl certificates.

## How it works

Some initial setup has to be done using a `Dockerfile`. Unfortunately, because the Docker container for
MariaDB runs as the `mysql` user (a good security practice), we can't copy in our `ssl.cnf` file at
runtime using the `docker-entrypoint.sh` script, as server config should be owned by root.

Further, we have to patch the `docker-entrypoint.sh` script too, because if we copy `ssl.cnf` before 
runtime, that means that this script will try to connect to an ssl-enabled server without ssl, and
will fail to complete initial setup.

The script `init-ssl.sh` generate self-signed certificates with a sensible set of default values.

## How to use it

You can connect to the running server over ssl by specifying `--ssl-ca` on the command line. Otherwise,
the client will not bother to verify the server certificate.

```
mysql -h127.0.0.1 -uroot -proot --ssl-ca=ca.pem
```

You can grab the `ca.pem` from the running server using:

```
docker run -it mariadbssl cat /etc/mysql/certs/ca.pem > ca.pem
```

## How to run the server

A command line is provided for convenience:

```
docker build --tag="mariadbssl" . && docker run -d -v"certs:/etc/mysql/certs" -v'dbs:/var/lib/mysql' -p"3306:3306/tcp" --name=mariadbssl mariadbssl
```

Hope this repository is useful for you.

## License

Public domain, 2023.
