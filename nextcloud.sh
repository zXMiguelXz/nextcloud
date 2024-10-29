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

echo -e "${LR}Instala sudo."
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
sudo apt install php libapache2-mod-php php-gd php-json php-xml php-mbstring php-curl php-zip php-intl php-bcmath php-gmp php-fpm php-mysql unzip curl -y &>> /dev/null


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
        sudo mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
        sudo mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
        sudo mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
        sudo mysql -u root -p"$r" -e "FLUSH PRIVILEGES"

    else
        echo "Tienes mariadb-server"
        read -p "Introduce la contraseña del usuario root: " r

        sudo mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
        sudo mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
        sudo mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
        sudo mysql -u root -p"$r" -e "FLUSH PRIVILEGES"
    fi
else
    echo "Tienes mysql-server"
    read -p "Introduce la contraseña del usuario root: " r

    sudo mysql -u root -p"$r" -e "CREATE DATABASE db_nextcloud"
    sudo mysql -u root -p"$r" -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$r'"
    sudo mysql -u root -p"$r" -e "GRANT ALL PRIVILEGES ON db_nextcloud.* TO 'nextcloud'@'localhost'"
    sudo mysql -u root -p"$r" -e "FLUSH PRIVILEGES"
fi

#Comprobacion de que no este nginx instalado
cn=$(dpkg -l | grep "^ii.*nginx")

if [[ $cn = "" ]];then
echo -e "${LY}Se ha comprobado que no tienes nginx${NC}"
else
echo -e "${LR}Tienes nginx instalado, este script funciona con el servidor web Apache2${NC}"
exit 1
fi

#Instalacion y configuracion servidor web
ca=$(dpkg -l | grep "^ii.*apache2")

if [[ $ca == "" ]]; then
echo -e "${LY}Se va a proceder a la instalacion de apache2${NC}"
wget -q --show-progress https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/iapache2.sh -O iapache2.sh
chmod +x iapache2.sh
sudo -E ./iapache2.sh
else
echo -e "${LY}Se va a proceder a configurar apache2, este script deshabilitara el 000-default para que nextcloud este funcionando en el puerto 80${LY}"
sleep 4
wget -q --show-progress https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/apache2.sh -O apache2.sh
chmod +x ./apache2.sh
sudo -E ./apache2.sh
fi

echo -e "${LG}Eliminando el directorio de trabajo.${NC}"
rm -R $HOME/next_setup/
sleep 2
echo ""
echo -e "${LG}Configuración completada. Ahora puedes acceder a Nextcloud en http://localhost.${NC}"
echo ""
echo -e "${LY}La base de datos se llama ${LG}db_nextcloud${NC}"
echo -e "${LY}El usuario se llama ${LG}nextcloud${NC}"
echo -e "${LY}La contraseña es ${LG}la misma que el usuario root${NC}"
echo ""
echo -e "${LG}Este script fue creado por Miguel Garcia Leon${NC}"
echo -e "${LY}https://github.com/zXMiguelXz${NC}"

