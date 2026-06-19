#!/bin/bash

declare -A SERVERS
SERVERS["vault-1"]="192.168.10.11"
SERVERS["vault-2"]="192.168.10.12"

for name in "${!SERVERS[@]}"; do
    ip="${SERVERS[$name]}"
    code=$(curl -o /dev/null -s -w "%{http_code}" http://${ip}:8200/v1/sys/health)
    
    case $code in
        200) status="ACTIVE" ;;
        429) status="STANDBY" ;;
        503) status="SEALED" ;;
        000) status="UNREACHABLE" ;;
        *)   status="UNKNOWN ($code)" ;;
    esac
    
    echo "${name}: ${code} ${status}"
done
