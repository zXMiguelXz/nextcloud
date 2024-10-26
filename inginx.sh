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

#Instalacion de nginx


sudo apt install nginx -y &>> /dev/null
echo -e "${LG}Nginx instalado.${NC}"


#Configuracion de nginx


PHP_VERSION=$(php -v | awk '{print $2}' | head -n 1 | cut -d. -f1,2)
USER_NEXTCLOUD_DIR="$HOME/next_setup/nextcloud"
NEXTCLOUD_DIR="/var/www/html/nextcloud"
NGINX_CONF="/etc/nginx/sites-available/nextcloud"
NGINX_ENABLED_CONF="/etc/nginx/sites-enabled/nextcloud"
WEB_USER="www-data"

#Moviendo Nextcloud a la carpeta de Nginx
echo -e "${LG}Moviendo Nextcloud a la carpeta web de Nginx.${NC}"
sudo mv "$USER_NEXTCLOUD_DIR" "$NEXTCLOUD_DIR"

#Configurando el archivo de servidor para Nextcloud
echo -e "${LG}Configurando Nginx para servir Nextcloud.${NC}"
sudo bash -c "cat << EOF > $NGINX_CONF
server {
    listen 80;
    server_name localhost;

    root $NEXTCLOUD_DIR;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock; 
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF"

#Dando permisos al usuario de Nginx
echo -e "${LG}Otorgando permisos a los archivos de Nextcloud.${NC}"
sudo chown -R $WEB_USER:$WEB_USER "$NEXTCLOUD_DIR"
sudo chmod -R 750 "$NEXTCLOUD_DIR"

#Deshabilitar el sitio predeterminado de Nginx y habilitar el sitio de Nextcloud
echo -e "${LY}Deshabilitando el sitio predeterminado y habilitando el sitio de Nextcloud.${NC}"
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
    echo -e "${LG}Sitio predeterminado de Nginx deshabilitado.${NC}"
else
    echo -e "${LG}No se encontró el sitio predeterminado de Nginx.${NC}"
fi
sudo ln -s $NGINX_CONF $NGINX_ENABLED_CONF

# Reiniciar Nginx
echo -e "${LY}Reiniciando Nginx para aplicar cambios.${NC}"
sudo systemctl restart nginx

echo -e "${LG}Configuración completada. Ahora puedes acceder a Nextcloud en http://localhost.${NC}"
