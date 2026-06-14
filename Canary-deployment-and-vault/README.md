# VAULT CLUSTER

| USER | GROUP | 
| ---- | ---- |
| Ansible | ansible, root |
| Fenitra | admin, root |
| Tojo | devops, adm |

### CONFIG DATABASE SERVER

```bash
cd /script
chmod +x key-gen.sh
./key-gen.sh
```
```bash
vagrant up
```

![script-output](images/script-output.png)
![ssh-vault](images/ssh-fenitra-vault-1.png)

![tojo](images/tojo-sudo-test.png)