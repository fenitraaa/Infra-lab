# NETWORK ATTACHED STORAGE (NAS)

## Network Topology
![Architecture](screenshot/Network%20Diagram.png)

## Vagrant Configuration
Create all 3 disks vmdk
```sh
for i in {1..3}; do
vmware-vdiskmanager -c -s 3GB -a lsilogic -t 2 disque$i.vmdk
done
vagrant plugin install vagrant-disksize
```
Launch all VMs
```
vagrant up
```
So you have 3 VMs in VMware Player:

![VMware](screenshot/VMware-VMs.png)


You can access all VMs using ssh
```
vagrant ssh ldap
vagrant ssh nas
vagrant ssh backup
```
Verify if all disk are recognized by nas server

![lsblk](screenshot/NAS-lsblk.png)


## NB: ALL ANSIBLE PLAYBOOKS ARE EXECUTED FROM HOST.

## LDAP Configuration

Directory Information Tree (DIT)

![DIT](screenshot/DIT.png)

Create ansible/group_vars/ldap/vault.yml
```
ldap_admin_password: your password
vault_linuxuser_password: linuxpassword
vault_windowsuser_password: windowspassword
```
and encrypt it:
```
ansible-vault encrypt group_vars/ldap/vault.yml
```

launch ansible-playbook

```
ansible-playbook site.yml --ask-vault-pass --tags openldap
```
![ansible-playbook command](screenshot/tags-openldap.png)



Execute the scipt to automate ldif configurations
``` 
cd /vagrant/ldap
chmod +x ./ldapadd_script.sh
./ldapadd_script.sh
```
![](screenshot/ldapadd_script.png)

## NAS Configurations

Firstly, we need to distribute and update CA certificate using this playbook's command.
```
ansible-playbook site.yml --ask-vault-pass --tags nas_ca_dist
```

![nas_dist](screenshot/tags-nas_ca_dist.png)

Then, install and configure samba so client nas can interact with ldap server and all client.

```
ansible-playbook site.yml --ask-vault-pass --tags nas_samba --asks-become-pass
```
> This playbook need privilege mode so using `--asks-become-pass` flag is necessary. By default, the password is: `vagrant`.

![nas_samba](screenshot/tags-nas_samba.png)