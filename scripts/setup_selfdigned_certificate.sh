#!/bin/bash
set -ex
#Importamos el archivo .env
source .env
# Creamos certificado autofirmado
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"
#Copiamos el archivo default-ssl.conf al servidor
cp ../conf/default-ssl.conf /etc/apache2/sites-available
#Habilitamos el sitio default-ssl.conf
a2ensite default-ssl.conf

#Habilitamos el modulo ssl de apache
sudo a2enmod ssl
#Copiamos el archivo de configuración de apache para redirigir HTTP a HTTPS
cp ../conf/000-default.conf /etc/apache2/sites-available

#Habilitamos el modulo rewrite de apache
sudo a2enmod rewrite

#Reiniciamos apache para aplicar los cambios
systemctl restart apache2