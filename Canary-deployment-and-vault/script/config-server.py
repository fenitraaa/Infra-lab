import grp
import os
import sys
import json
import subprocess
import pwd

user_config = "user.json"

def load_config():
    if not os.path.exists(user_config):
        print("file not found")
        sys.exit(1)
    with open(user_config, "r") as f:
        return json.load(f)

def run_command(command):
    subprocess.run(command, shell=True, check=True)

def name_exist(name, silent=False):
    try:
        username = pwd.getpwnam(name)
        if not silent:
            print (f"User already exist: {username.pw_name}.")
        return True
    except KeyError:
        return False

def group_exist(group_name):
    try:
        groupe = grp.getgrnam(group_name)
        print (f"Group already exist: {groupe.gr_name}.")
        return True
    except KeyError:
        return False

def create_users():
    data = load_config()
    users = data.get("users", [])
    print("== USER CREATION ==")
    for user in users:
        username = user["name"]
        primary_group = user["group"]
        secondary_group = user.get("groups", [])

        print(f"[ ] USER: {username.swapcase()}")
        if group_exist(primary_group):
            pass
        else:
            run_command(f"groupadd {primary_group}")
            print("Primary Group added.")
        for sec_group in secondary_group:
            if group_exist(sec_group):
                pass
            else:
                run_command(f"groupadd {sec_group}")
                print("Secondary Group added.")
        if name_exist(username, silent=True): 
            print(f"User {username} already exist.")
        else:
            if secondary_group:
                group_join = ",".join(secondary_group)
                run_command(f"useradd -m -s /bin/bash -g {primary_group} -G {group_join} {username}")
            else:
                run_command(f"useradd -m -s /bin/bash -g {primary_group} {username}")
            print("User added.")
        print(f"[+] USER: {username.swapcase()}")

def config_ssh():
    data  = load_config()
    users = data.get("users", [])   
    print("\n== SSH CONFIGURATION FOR ALL CREATED USER ==")
    for user in users:
        username = user["name"]
        key_file = user.get("pub_key", "")
        print(f"[ ] USER: {username.swapcase()}")
        if not key_file or not os.path.isfile(key_file):
            print(f"Public key for {username.swapcase()} not found.")
            continue
        else:
            with open(key_file, "r") as k:
                value = k.read().strip()
            ssh_dir = f"/home/{username}/.ssh"
            auth_keys   = f"{ssh_dir}/authorized_keys"
            os.makedirs(ssh_dir, mode=0o700, exist_ok=True)
            with open(auth_keys, "w") as f:
                f.write(value + "\n")
            uid = pwd.getpwnam(username).pw_uid
            gid = pwd.getpwnam(username).pw_gid
            os.chown(ssh_dir, uid, gid)
            os.chown(auth_keys, uid, gid)
            os.chmod(auth_keys, 0o600)
            print(f"[+] USER: {username.swapcase()}")

def config_sudo():
    data = load_config()
    users = data.get("users", [])
    sudo_command = data.get("sudo_commands", {})
    role = sudo_command["roles"]
    print("\n== SUDO CONFIGURATION ==")
    for user in users:
        username = user["name"]
        print(f"[ ] USER : {username.swapcase()}")
        sudo_role = user["sudo"]
        role_value = role.get(sudo_role)
        categories = sudo_command.get("categories", {})
        if role_value == "ALL":
            run_command(f"usermod -aG sudo {username}")
            print(f"User {username} added on sudo group.")
            sudoers_file = f"/etc/sudoers.d/{username}"
            with open(sudoers_file, "w") as f:
                    f.write(f"{username} ALL=(ALL) NOPASSWD: ALL\n")
                    print(f"sudoers file created for user {username}")
            print(f"[+] USER: {username.swapcase()}")
        else:
            cmds = []
            for cat_name in role_value:
                for cmd in categories.get(cat_name, []):
                    cmds.append(cmd)
            sudoers_file = f"/etc/sudoers.d/{username}"
            lines = "\n".join(
                f"{username} ALL=(ALL) NOPASSWD: {cmd}"
                for cmd in cmds
            )
            with open(sudoers_file, "w") as f:
                f.write(f"\n{lines}\n")
            os.chmod(sudoers_file, 0o440)
            print(f"User {username} added on sudoers.")
            result = subprocess.run(
                f"visudo -cf {sudoers_file}",
                shell=True,
                check=False,
                capture_output=True
            )
            if result.returncode != 0:
                os.remove(sudoers_file)
                print(f"misy olana ndray lety : {username}")
                sys.exit(1)
    print(f"[+] USER: {username.swapcase()}")
            
def disable_user_vagrant():
    print("\n== DISABLE USER VAGRANT ==")
    if name_exist("vagrant", silent=True):
        run_command("usermod -L vagrant")
        print("[+] Password for USER Vagrant disabled.")
    else:
        print("tsisy anzany ato eh")

def harden_ssh():
    os.makedirs("/etc/ssh/sshd_config.d", exist_ok=True)
    print("== HARDENING SSH CONGIGURATIONS")
    config = (
        "PermitRootLogin no\n"
        "PasswordAuthentication no\n"
        "PubkeyAuthentication yes\n"
        "MaxAuthTries 3\n"
        "AllowAgentForwarding no\n"
        "X11Forwarding no\n"
        "ClientAliveInterval 300\n"
        "ClientAliveCountMax 2\n"
    )
    with open("/etc/ssh/sshd_config.d/hardening.conf", "w") as f:
        f.write(config)

    run_command("sshd -t")
    run_command("systemctl restart sshd")
    print("[+] SSH hardened.")

if __name__ == "__main__":
    create_users()
    config_ssh()
    config_sudo()
    disable_user_vagrant()
    harden_ssh()
    