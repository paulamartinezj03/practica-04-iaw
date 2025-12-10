# practica-04-iaw
# Configuramos el archivo de deploy.sh
## !/bin/bash
set -ex
## Importamos el archivo .env
source .env
## Eliminamos las descargas previas del repositorio
rm -rf /tmp/iaw-practica-lamp
## Clonamos el repositorio con el código de la aplicación web
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp
## Movemos el código fuente de la aplicación a /var/www/html
mv /tmp/iaw-practica-lamp/src/* /var/www/html/
## Creamos una base de datos, un usuario y una contraseña
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME"
mysql -u root -e "DROP USER IF EXISTS $DB_USER@'%'"
mysql -u root -e "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD'"
## Le asignamos privilegios al usuario
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'"
## Modificamos el archivo de configuración config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php
## Ejecutamos el script de creación de tablas
mysql -u root $DB_NAME < /tmp/iaw-practica-lamp/db/database.sql
# Configuramos setup_selfdigned_certificate.sh
## !/bin/bash
set -ex
## Importamos el archivo .env
source .env
## Creamos certificado autofirmado
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"
## Copiamos el archivo default-ssl.conf al servidor
cp ../conf/default-ssl.conf /etc/apache2/sites-available
## Habilitamos el sitio default-ssl.conf
a2ensite default-ssl.conf

## Habilitamos el modulo ssl de apache
sudo a2enmod ssl
## Copiamos el archivo de configuración de apache para redirigir HTTP a HTTPS
cp ../conf/000-default.conf /etc/apache2/sites-available

## Habilitamos el modulo rewrite de apache
sudo a2enmod rewrite

## Reiniciamos apache para aplicar los cambios
systemctl restart apache2
![](images/ejecucion%20certificado.png)
