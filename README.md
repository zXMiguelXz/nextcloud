# Instalación automatizada de nextcloud
Ejecutar:
```
wget https://raw.githubusercontent.com/zXMiguelXz/nextcloud/refs/heads/main/nextcloud.sh  && chmod +x nextcloud.sh && bash nextcloud.sh
```
# Habilitar aplicaciones
Tendremos que hacer lo siguiente:

Habilitamos los trabajos de fondo


```
sudo -u www-data php /var/www/html/nextcloud/occ background:cron
```
Añadimos lo siguiente en el archivo crontab
```
sudo crontab -u www-data -e

```

```
*/15 * * * * php -f /var/www/html/nextcloud/cron.php
*/5 * * * * php /var/www/html/nextcloud/occ background-job:worker

```
