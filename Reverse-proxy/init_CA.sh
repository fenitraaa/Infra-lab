#!/bin/bash

set -e

mkdir -p /shared/ca

cd /shared/ca

if [ ! -f ca.key ]; then

  echo "[CA] Generate private key..."

  openssl genrsa -out ca.key 4096

  echo "[CA] Generate certificat CA..."

  openssl req -x509 -new -nodes \
    -key ca.key \
    -sha256 \
    -days 3650 \
    -out ca.crt \
    -subj "/C=MG/ST=Fianarantsoa/L=Tanambao/O=SecWeb/CN=ca.com"

fi

if [ -f /shared/proxy/proxy.csr ]; then

  mkdir -p /shared/proxy

  else 

  echo "[CA] Proxy certificate signing..."

  openssl x509 -req \
    -in /shared/proxy/proxy.csr \
    -CA /shared/ca/ca.crt \
    -CAkey /shared/ca/ca.key \
    -CAcreateserial \
    -out /shared/proxy/proxy.crt \
    -days 365 \
    -sha256

fi

echo "[CA] Copy ca.crt to local certificates..."

sudo cp /shared/ca/ca.crt /usr/local/share/ca-certificates/secweb-ca.crt
sudo update-ca-certificates

echo "[CA] Done."
