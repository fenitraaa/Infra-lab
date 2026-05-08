#!/bin/bash

set -e

mkdir -p /shared/ca

cd /shared/ca

if [ ! -f ca.key ]; then

  echo "[CA] Génération clé privée CA..."

  openssl genrsa -out ca.key 4096

  echo "[CA] Génération certificat CA..."

  openssl req -x509 -new -nodes \
    -key ca.key \
    -sha256 \
    -days 3650 \
    -out ca.crt \
    -subj "/C=MG/ST=Fianarantsoa/L=Tanambao/O=SecWeb/CN=ca.com"

fi

if [ -f /shared/proxy/proxy.csr ]; then

  mkdir -p /shared/proxy

  echo "[CA] Signature certificat proxy..."

  openssl x509 -req \
    -in /shared/proxy/proxy.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out /shared/proxy/proxy.crt \
    -days 365 \
    -sha256

fi

echo "[CA] Terminé"
