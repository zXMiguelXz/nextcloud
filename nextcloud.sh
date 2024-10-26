####################################################################################################################
#Hecho por Miguel Garcia Leon
#Octubre 2024
####################################################################################################################


#Estilo de las letras
LR='\033[0;91m'
LG='\033[0;92m'
LY='\033[0;93m'
NC='\033[0m'

#Comprueba que no lo ejecute el usuario root
if [[ $EUID -eq 0 ]]; then
    echo
    echo -e "${LR}NO ejecutar este script como ROOT." 1>&2
    echo -e ${NC}
    exit 1
fi

#Comprueba que el paquete sudo este instalado
comprobar_sudo=$(dpkg -l | grep sudo)
if
[[ $comprobar_sudo == "" ]];then

echo -e "${LR}Instalasudo."
echo -e ${NC}
exit 1
else
echo -e "${LG}Haciendo algunas comprobaciones..."
echo -e ${NC}
sleep 1

fi

#Comprobar que el usuario esta en el grupo sudo
if ! id -nG "$USER" | grep -qw "sudo"; then
    echo
    echo -e "${LRED}El usuario (${USER}) no esta en el grupo sudo. Ejecuta: sudo usermod -aG sudo ${USER}${NC}" 1>&2
    exit 1
fi

#Comprobacion si el usuario esta en /etc/sudoers
SUDO_FILE=$(sudo cat /etc/sudoers)

if [[ $SUDO_FILE == "" ]];then
echo -e "${LR}El usuario $USER no esta en el archivo /etc/sudoers"
exit 1
else
echo ""
fi

#Creacion de entorno de trabajo
HOME=$(eval echo ~)
rm -R $HOME/next_setup/
mkdir $HOME/next_setup
DOWNLOAD=$HOME/next_setup

comprobar_carpeta=$(ls $HOME | grep next_setup)

if [[ $comprobar_carpeta == "" ]];then

echo -e "${LR}No se ha podido crear correctamente el espacio de trabajo"
echo -e "${NC}"
exit 1

else
echo -e "${LG}Espacio de trabajo creado correctamente"
echo -e "${NC}"
fi


#Actualizando el sistema
sudo apt update -qq  &> /dev/null && sudo apt upgrade  &> /dev/null
echo -e "${LG}El sistema se ha actualizado de forma correcta.${NC}"

#Instalando paquetes
sudo apt install gpg zip unzip wget -y &> /dev/null
echo -e "${LG}Se ha instalado los paquetes necesarios.${NC}"

#Descargar nextcloud
echo -e "${LY}Descargando Nextcloud${NC}"
echo ""
cd $DOWNLOAD
wget -q --show-progress https://download.nextcloud.com/server/releases/latest.zip -O lastest.zip

echo -e "${LY}Añadiendo claves de Nextcloud${NC}"
gpg --keyserver keys.openpgp.org --recv-keys 28806A878AE423A28372792ED75899B9A724937A &>> /dev/null

echo -e "${LY}Desempaquetando nextcloud${NC}"
unzip lastest.zip &>> /dev/null

comprobar_nextcloud=$(ls $DOWNLOAD | grep nextcloud)

if [[ $comprobar_nextcloud == "" ]];then

echo -e "${LR}No se ha podido descomprimir correctamente."
echo -e "${NC}"
exit 1
else
echo -e "${LG}Nextcloud descomprimido correctamente"
echo -e "${NC}"
fi

#Dependencias nextcloud
echo -e "${LY}Instalando dependencias${NC}"
sudo apt update &>> /dev/null
sudo apt install php libapache2-mod-php php-gd php-json php-xml php-mbstring php-curl php-zip php-intl php-bcmath php-gmp php-fpm unzip curl -y &>> /dev/null


echo -e "${LG}Dependencias instaladas${NC}"



#Base de datos
echo -e "${LG}Configuracion de base de datos${NC}"
my=$(dpkg -l | grep "^ii.*mysql-server")
ma=$(dpkg -l | grep "^ii.*mariadb-server")

if [[ -z $my ]]; then
    if [[ -z $ma ]]; then
        echo -e "${LG}Instalando mariadb-server"
        sudo apt install mariadb-server mariadb-client -y &>> /dev/null
        read -p "Introduce la contraseña del usuario root: " r
        mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
        mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
        mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
        mysql -u root -p"$r" -e "FLUSH PRIVILEGES"

    else
        echo "Tienes mariadb-server"
        read -p "Introduce la contraseña del usuario root: " r

        mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
        mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
        mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
        mysql -u root -p"$r" -e "FLUSH PRIVILEGES"
    fi
else
    echo "Tienes mysql-server"
    read -p "Introduce la contraseña del usuario root: " r

    mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
    mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
    mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
    mysql -u root -p"$r" -e "FLUSH PRIVILEGES"
fi

#Instalacion y configuracion servidor web
ca=$(dpkg -l | grep "^ii.*apache2")
cn=$(dpkg -l | grep "^ii.*nginx")

if [[ $ca == "" ]]; then
    if [[ $cn == "" ]]; then
        SERVER_WEB="nada"
    else
        SERVER_WEB="nginx"
    fi
else
    SERVER_WEB="apache2"
fi

if [[ $SERVER_WEB == "nginx" ]]; then
wget https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/nginx.sh -O nginx.sh
chmod +x nginx.sh
    sudo -E ./nginx.sh
elif [[ $SERVER_WEB == "apache2" ]]; then
wget https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/apache.sh -O apache.sh
chmod +x apache2.sh
    sudo -E ./apache2.sh
else
    echo -e "${LY}Ahora se va a instalar un servidor web, elige una de las opciones"
    sleep 4

    while true; do
        echo "Elige una opción:"
        echo "1) Instalar Apache2"
        echo "2) Instalar Nginx"
        read -p "Elige una opción: " option
        case $option in
            1)
wget https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/iapache.sh -O iapache.sh
chmod +x iapache2.sh
sudo -E ./iapache2.sh
break
                ;;
            2)
wget https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/nginx.sh -O nginx.sh
chmod +x inginx.sh
sudo -E ./inginx.sh

break
 ;;
            *)
                echo "Opción inválida, por favor intenta de nuevo."
                ;;
        esac
    done
fi

echo ""
echo -e "${LG}Este script fue creado por Miguel Garcia Leon${NC}"
echo -e "${LY}https://github.com/zXMiguelXz${NC}"
