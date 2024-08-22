#!/bin/bash
if (($EUID !=0)); then
     echo Script must be run by root.
     exit
fi

if [ $# -eq 0 ]; then
    echo "Usage $0: <Domain Name linked to your VPS>"
    exit 1
fi

echo "Installing requirements. "
apt-get install -y docker docker-compose curl qrencode
uuuid=$(cat /proc/sys/kernel/random/uuid)
cp Caddyfile Caddifile.original
cp config.json config.json.original
sed -i "s/domain_name/$1/g" Caddyfile
sed -i "s/uuuuid/$uuuid/g" config.json
echo 'Files Caddyfile and config.json is changed by your settings. Original files saved with .original postfix.'
sleep 5
docker-compose up -d
docker ps

link='vless://'$uuuid'@'$1':443?security=tls&fp=chrome&type=ws&path=/topsecretpath&encryption=none#WS'

echo "Client link and QR-code: "
echo $link
qrencode -t ANSIUTF8 $link
echo ''
echo ''
echo ''
echo $link > link.txt
echo 'Link saved in file links.txt'
