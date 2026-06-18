#!/bin/bash

USERS=("fenitra" "ansible" "tojo")
declare -A SERVERS
SERVERS["db"]="192.168.10.10"
SERVERS["vault-1"]="192.168.10.11"
SERVERS["vault-2"]="192.168.10.12"
SERVERS["haproxy"]="192.168.10.20"
mkdir -p "$HOME/.ssh"
echo -n "" > "$HOME/.ssh/config"

for user in "${USERS[@]}"; do
    echo "USER : ${user^^}"
    if [ -f "$HOME/.ssh/lab-$user" ]; then
        echo "Key already exists for user ${user^^}"
    else 
        ssh-keygen -t ed25519 -C "lab-$user" -f "$HOME/.ssh/lab-$user" -N ""
        cp "$HOME/.ssh/lab-$user.pub" .
    fi
    for server_name in "${!SERVERS[@]}"; do
        ip="${SERVERS["$server_name"]}"
        cat << EOF >> "$HOME/.ssh/config"
Host lab-${user}-${server_name}
    HostName ${ip}
    User ${user}
    IdentityFile ~/.ssh/lab-${user}
EOF
    done
done
