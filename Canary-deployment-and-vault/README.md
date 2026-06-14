# CANARY DEPLOYMENT AND VAULT

This project try to simulate an infrastructure like production ready, so all the user are supose to be real.

| USER | GROUP | DESCRIPTION |
| ---- | ---- | ---- |
| Ansible | ansible, root | service account for ansible-playbook client |
| Fenitra | admin, root | account for system administrator |
| Tojo | devops, adm | account for devops engineer with limited autorisation |

### CONFIGURATION FOR HOST
Inside the host, we should create key ssh for all user account and copy in `$HOME/.ssh/config` file.

```bash
cd /script
chmod +x key-gen.sh
./key-gen.sh
```

And then we can create our servers using vagrant. Inside this vagrantfile, there's a script `config-server.py` that config automatically all user account for all existing servers.
```bash
vagrant up
```

![script-output](images/script-output.png)

After all of this config, we can intercat with VM using `ssh + lab-username + server_name`.
For example:
```bash
ssh lab-fenitra-vault-1
```

![ssh-vault](images/ssh-fenitra-vault-1.png)

All autorisation are set for user `Tojo` the devops engineer. So he can execute `systemctl` command but can't install new packages.

![tojo](images/tojo-sudo-test.png)

```bash
ansible-playbook -i inventory.yml site.yml --tags vault-installation --limit vault-1
```
![vault-installation](images/vault-installation.png)