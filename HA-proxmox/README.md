# Cluster Proxmox Haute Disponibilité (lab-HA) — Hébergement de l'application AI Weather

## 1. Présentation

Ce projet met en place, dans un environnement de laboratoire virtualisé (VirtualBox), une infrastructure Proxmox VE 9.2 en haute disponibilité (HA). Elle héberge une application web conteneurisée.

## 2. Architecture

![Architecture](<proxmox-HA.svg>)

## 3. Étapes de réalisation

### 3.1 Installation de Proxmox VE

Démarrage de l'ISO Proxmox VE 9.2 dans une machine virtuelle VirtualBox.

![Menu de démarrage de l'installeur Proxmox](<screenshot/Screenshot 2026-10-03 101055.png>)

Lancement de l'installation (création des partitions) sur la VM `proxmox-lab`.

![Installeur Proxmox VE en cours](<screenshot/Screenshot 2026-10-04 000030.png>)

Après installation, la console indique l'URL d'administration (`https://10.0.2.15:8006/`).

![Console Proxmox après installation](<screenshot/Screenshot 2026-10-04 113510.png>)

L'interface web est accessible depuis la machine hôte via `https://localhost:8006` (redirection de port VirtualBox), avec connexion `root` (Linux PAM).

![Page de connexion Proxmox VE](<screenshot/Screenshot 2026-10-04 113559.png>)

### 3.2 Premier conteneur LXC (`node-1`) et Docker

Un conteneur LXC Ubuntu 24.04 LTS (`101 – node-1`) est créé sur le nœud `pve`.

![Console du conteneur 101 node-1](<screenshot/Screenshot 2026-10-11 094626.png>)

Docker (`docker-ce`, `containerd`, plugins `buildx` et `compose`) y est installé.

![Installation de Docker dans node-1](<screenshot/Screenshot 2026-10-11 102510.png>)

L'assistant de création de conteneur LXC (conteneur non privilégié, option Nesting activée, indispensable pour faire tourner Docker dans un LXC) :

![Assistant de création d'un conteneur LXC](<screenshot/Screenshot 2026-10-11 171021.png>)

### 3.3 Les trois machines virtuelles du cluster

Trois VMs Proxmox (`pve1`, `pve2`, `pve3`) tournent dans VirtualBox.

![Gestionnaire VirtualBox avec pve1, pve2, pve3](<screenshot/Screenshot 2026-10-11 170722.png>)

### 3.4 Création du cluster et du QDevice

Le cluster `lab-HA` est formé : `pve2` rejoint `pve1` (192.168.100.10) via l'assistant Cluster Join (jointure assistée, empreinte vérifiée).

![Cluster Join sur pve2](<screenshot/Screenshot 2026-10-11 150642.png>)

Un cluster à 2 nœuds ne peut pas maintenir le quorum si l'un tombe. On ajoute donc un vote externe (QDevice) sur `pve3` :

- Installation de `corosync-qnetd` sur `pve3` :

![Installation de corosync-qnetd sur pve3](<screenshot/Screenshot 2026-10-11 150207.png>)

- Installation de `corosync-qdevice` sur `pve1` et `pve2` :

![Installation de corosync-qdevice sur pve1](<screenshot/Screenshot 2026-10-11 150223.png>)

![Installation de corosync-qdevice sur pve2](<screenshot/Screenshot 2026-10-11 150457.png>)

- Autorisation de la connexion SSH `root` sur `pve3` (nécessaire à la configuration du QDevice) :

![Configuration sshd sur pve3](<screenshot/Screenshot 2026-10-11 150353.png>)

- Vérification du service `corosync-qnetd` (actif) :

![Statut de corosync-qnetd](<screenshot/Screenshot 2026-10-11 150417.png>)

- Configuration depuis `pve1` avec `pvecm qdevice setup 192.168.100.12` :

![pvecm qdevice setup](<screenshot/Screenshot 2026-10-11 150803.png>)

Résultat : 3 votes attendus, quorum = 2, flag `Quorate Qdevice`. Le cluster survit à la perte d'un nœud.

![Quorum avec QDevice](<screenshot/Screenshot 2026-10-11 150849.png>)

### 3.5 Déploiement de l'application AI Weather

Dans `node-1`, le front-end est lancé avec Docker, exposé sur le port 8080 et avec `--restart always` :

```bash
docker run -d --name aiweather --restart always -p 8080:80 ghcr.io/fenitraaa/aiweather-front:latest
```

![Lancement du conteneur aiweather](<screenshot/Screenshot 2026-10-11 155630.png>)

L'application affiche la météo du jour (température, précipitations, vent), des prévisions sur 7 jours, un historique et un graphique de prédiction. Elle est accessible sur `aiweather.test:8080`.

![Application AI Weather](<screenshot/Screenshot 2026-10-11 171549.png>)

### 3.6 Accès réseau : NAT et load balancer

Sur `pve1` et `pve2`, le routage IP est activé et le trafic arrivant sur le port 8080 est redirigé (DNAT) vers le conteneur `10.0.2.50:8080`, avec MASQUERADE. Ainsi, quel que soit le nœud qui héberge le conteneur, le service reste joignable sur l'IP du nœud.

```bash
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forward.conf
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 8080 -j DNAT --to-destination 10.0.2.50:8080
iptables -t nat -A POSTROUTING -d 10.0.2.50 -p tcp --dport 8080 -j MASQUERADE
```

![NAT sur pve1](<screenshot/Screenshot 2026-10-11 160943.png>)

![NAT sur pve2](<screenshot/Screenshot 2026-10-11 160815.png>)

Test depuis `pve3` : le service répond `HTTP/1.1 200 OK` (serveur Nginx) sur `192.168.100.10:8080`.

![Test curl depuis pve3](<screenshot/Screenshot 2026-10-11 161640.png>)

HAProxy est installé sur `pve3` pour servir de point d'entrée unique et répartir/rediriger le trafic vers le nœud actif.

![Installation de HAProxy](<screenshot/Screenshot 2026-10-11 161707.png>)

![Service HAProxy actif](<screenshot/Screenshot 2026-10-11 161730.png>)

### 3.7 Mise en haute disponibilité du conteneur

Le conteneur CT 101 est ajouté comme ressource HA (état demandé `started`, 1 redémarrage max, 1 relocalisation max, failback et auto-rebalance activés). Proxmox rappelle qu'au moins trois votes de quorum sont recommandés, d'où l'intérêt du QDevice.

![Ajout du CT 101 aux ressources HA](<screenshot/Screenshot 2026-10-11 153101.png>)

Le statut HA confirme : quorum OK, fencing armé (watchdog CRM actif), master `pve1`, `ct:101` démarré sur `pve1`.

![Statut HA du datacenter](<screenshot/Screenshot 2026-10-11 171631.png>)

### 3.8 Stockage ZFS et réplication

Deux disques virtuels de 20 Go sont créés dans VirtualBox pour `pve1` et `pve2`.

![Création des disques VDI](<screenshot/Screenshot 2026-10-11 192123.png>)

Sur chaque nœud, un pool ZFS `zfs-data` est créé sur `/dev/sdb` (`ashift=12`, compression `lz4`). Sur `pve2`, la taille maximale du cache ARC est limitée à 512 Mo (`zfs_arc_max=536870912`) pour économiser la mémoire de la VM.

![Pool ZFS sur pve1](<screenshot/Screenshot 2026-10-11 195347.png>)

![Pool ZFS sur pve2](<screenshot/Screenshot 2026-10-11 195709.png>)

Le pool est déclaré comme stockage Proxmox sur les deux nœuds (contenu `rootdir,images`) ; `pvesm status` liste `local`, `local-lvm`, `nfs-shared` et `zfs-data`.

![Ajout du stockage zfs-data](<screenshot/Screenshot 2026-10-11 195830.png>)

Une tâche de réplication du CT 101 vers `pve2` est créée, toutes les 15 minutes.

![Création du job de réplication](<screenshot/Screenshot 2026-10-11 200436.png>)

`pvesr status` confirme son bon fonctionnement (état OK, 0 échec).

![Statut de la réplication](<screenshot/Screenshot 2026-10-11 200545.png>)

## 4. Test de basculement (failover)

Pour simuler une panne, la VM `pve1` est éteinte brutalement depuis VirtualBox.

![Extinction de pve1 dans VirtualBox](<screenshot/Screenshot 2026-10-11 202815.png>)

Résultat observé sur `pve2` : `pve1` est détecté comme mort, `pve2` devient master HA, et le service `ct:101` est redémarré automatiquement sur `pve2`. Le quorum reste OK grâce au QDevice.

![Failover : ct:101 redémarré sur pve2](<screenshot/Screenshot 2026-10-11 203346.png>)

