# INFRA-LAB
As a SYSTEM & NETWORK ADMINISTRATOR and DEVOPS/SRE, all my project academic and personal are in this repository with their `Documentation`. Built with the following tools:

| CONCEPT | TOOLS | VERSION |  
| ---- | ---- | ---- |
| Containerization | Docker<br>Docker Compose | 29.5.3<br>1.29.2 |
| CI/CD | Jenkins | 1.34.2 |
| Automatisation | Python<br>Bash<br>Groovy | 3.12.3<br>5.2.21<br>DSL for Jenkins |
| Infrastructure as Code | Vagrant | 2.4.9 |
| Configuration as Code | Ansible | 2.16.3 |
| OS | Ubuntu Server<br>Debian |  22.04 LTS<br>12 |
| Orchestration | Kubernetes(Kubeadm) | 1.34.2 |
| Versioning | Git | 2.43.0 |
| Virtualisation | VMware<br>Virtualbox | 25.0.0<br>7.2.8 |
| Credentials management | Vault HashiCorp<br>KeePass | 1.18.3<br>2.7.12 |
| Network Tools | GNS3<br>Wireguard<br>Wireshark | 2.2.50<br>1.0.20210914<br>4.6.6  |

You have to create the virtual environnements for `python3`:
```bash
python3 -m venv env-infra
source env-infra/bin/activate
pip install -r requirements.txt

```