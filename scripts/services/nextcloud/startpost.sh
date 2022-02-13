#!/bin/bash

ENV_FILE=/opt/misborn/.env

if [ -f "${ENV_FILE}" ]; then
    export $(cat ${ENV_FILE} | xargs)
fi

HTTPD="404"
until [ "$HTTPD" == "200" ]; do
    echo "Waiting for Nextcloud to start..."
    sleep 3
    HTTPD=$(curl -A "Web Check" -sL --connect-timeout 3 -w "%{http_code}\n" "http://nextcloud.${MISTBORN_BASE_DOMAIN}" -o /dev/null)
done

echo "Nextcloud is running! Setting config.php variables."

docker-compose -f /opt/mistborn/extra/nextcloud.yml exec nextcloud su -p www-data -s /bin/sh -c "php /var/www/html/occ config:system:set verify_peer_off --value=true"
docker-compose -f /opt/mistborn/extra/nextcloud.yml exec nextcloud su -p www-data -s /bin/sh -c "php /var/www/html/occ config:system:set allow_local_remote_servers --value=true"
