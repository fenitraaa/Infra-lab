#!/bin/bash

set -e

mkdir -p /shared/proxy

cd /shared/proxy


if [ ! -f proxy.key ]; then

  echo "[PROXY] Génération clé privée..."

  openssl genrsa -out proxy.key 2048

fi

if [ ! -f proxy.csr ]; then

  echo "[PROXY] Génération CSR..."

  openssl req -new \
    -key proxy.key \
    -out proxy.csr \
    -subj "/C=MG/ST=Antananarivo/L=Antananarivo/O=SecWeb/CN=proxy.com"

fi

echo "[PROXY] Attente certificat CA..."

while [ ! -f /shared/proxy/proxy.crt ]; do
  sleep 2
done

echo "[PROXY] Certificat reçu"


cat > /etc/nginx/sites-available/default <<EOF

server {

    listen 443 ssl;

    server_name proxy.com;

    ssl_certificate     /shared/proxy/proxy.crt;
    ssl_certificate_key /shared/proxy/proxy.key;

    location / {
        proxy_pass http://frontend:80;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

}

EOF

systemctl restart nginx

echo "[PROXY] OK"
