#!/usr/bin/bash

cd /etc/mysql/certs

# https://serverfault.com/questions/622317/mysql-ssl-bad-other-signature-confirmation/1128792
# Generate a CA key and certificate with SHA1 digest
openssl genrsa 2048 > ca-key.pem
openssl req -sha256 -new -x509 -nodes -days 3650 -key ca-key.pem \
    -subj "/C=GB/ST=Co. Durham/L=Durham/O=Durham University/CN=localhost" > ca-cert.pem

# Create server key and certficate with SHA1 digest, sign it and convert
# the RSA key from PKCS #8 (OpenSSL 1.0 and newer) to the old PKCS #1 format

openssl req -sha256 -newkey rsa:2048 -days 3650 -nodes \
    -subj "/C=GB/ST=Co. Durham/L=Durham/O=Durham University/CN=localhost" \
    -keyout server-key.pem > server-req.pem
openssl x509 -sha256 -req -in server-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > server-cert.pem
openssl rsa -traditional -in server-key.pem -out server-key.pem

# Create client key and certificate with SHA digest, sign it and convert
# the RSA key from PKCS #8 (OpenSSL 1.0 and newer) to the old PKCS #1 format

openssl req -sha256 -newkey rsa:2048 -days 3650 -nodes \
    -subj "/C=GB/ST=Co. Durham/L=Durham/O=Durham University/CN=www.example.com" \
    -keyout client-key.pem > client-req.pem
openssl x509 -sha256 -req -in client-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > client-cert.pem
openssl rsa -in client-key.pem -out client-key.pem

echo "# Provide both of the below certs to the mysql client" > ca.pem
echo "# to connect using:" >> ca.pem
echo "# \`mysql -h127.0.0.1 -uroot -proot --ssl-ca=ca.pem\`" >> ca.pem
echo >> ca.pem
echo "# Server Certificate:" >> ca.pem
cat server-cert.pem >> ca.pem
echo -e "\n# Client Certificate:" >> ca.pem
cat client-cert.pem >> ca.pem

chown mysql:mysql *.pem
chmod 600 *.pem

