#!/bin/bash
####################################################################################################################
#Hecho por Miguel Garcia Leon
#Octubre 2024
####################################################################################################################

#Estilo de las letras
LR='\033[0;91m'
LG='\033[0;92m'
LY='\033[0;93m'
NC='\033[0m'


#Instalacion de apache


sudo apt install apache2 -y &>> /dev/null
echo -e "${LG}Apache instalado.${NC}"


#Configuracion de apache
USER_NEXTCLOUD_DIR="$HOME/next_setup/nextcloud"
NEXTCLOUD_DIR="/var/www/html/nextcloud"
APACHE_CONF="/etc/apache2/sites-available/nextcloud.conf"
WEB_USER="www-data"

#Moviendo Nextcloud a la carpeta de Apache
echo -e "${LG}Moviendo Nextcloud a la carpeta web de Apache.${NC}"
sudo mv "$USER_NEXTCLOUD_DIR" "$NEXTCLOUD_DIR"

#Configurando el archivo de virtual host para Nextcloud
echo -e "${LG}Configurando Apache para servir Nextcloud.${NC}"

sudo bash -c "cat << EOF > $APACHE_CONF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $NEXTCLOUD_DIR

    <Directory $NEXTCLOUD_DIR>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOF"

#Dando permisos al usuario de Apache
echo -e "${LG}Otorgando permisos a los archivos de Nextcloud.${NC}"
sudo chown -R $WEB_USER:$WEB_USER "$NEXTCLOUD_DIR"
sudo chmod -R 750 "$NEXTCLOUD_DIR"

#Deshabilitar el sitio predeterminado y habilitar el sitio de Nextcloud
echo -e "${LG}Deshabilitando 000-default.conf y habilitando nextcloud.conf.${MC}"
sudo a2dissite 000-default.conf
sudo a2enmod rewrite headers env dir mime
sudo a2ensite nextcloud.conf

#Reiniciar Apache
echo -e "${LY}Reiniciando Apache para aplicar cambios.${NC}"
sudo systemctl restart apache2

echo -e "${LG}Configuración completada. Ahora puedes acceder a Nextcloud en http://localhost.${NC}"


