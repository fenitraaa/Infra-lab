# VoIP project

### Installation and Configuration for Asterisk server

All dependencies installation are done with an `ansible` playbook, just execute the following commands:

```bash
ansible-playbook -i inventory.yml site.yml --tags asterisk-installation
```
![installation](screenshot/asterisk-installation-tags.png)

