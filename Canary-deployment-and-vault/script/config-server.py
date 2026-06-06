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

def name_exist(name):
    try:
        username = pwd.getpwnam(name)
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

def encrypt_password(password):
    input_passord = subprocess.run(
        ["openssl", "passwd", "-6", password],
        text=True,
        capture_output=True,
        check=True
    )
    return input_passord.stdout.strip()

def user_has_password(username):
    try:
        result = subprocess.run(
            ["passwd", "-S", username],
            text=True,
            capture_output=True,
            check=True
        )
        status_info = result.stdout.strip().split()
        status = status_info[1]
        if status == "P":
            print(f"{username} has password already.")
            return True
    except subprocess.CalledProcessError:
        return False

def create_users():
    data = load_config()
    users = data.get("users", [])
    for user in users:
        username = user["name"]
        primary_group = user["group"]
        secondary_group = user.get("groups", [])

        print(f"User: {username}")
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
        if name_exist(username):
            if not user_has_password(username):
                password = os.getenv("PASSWD")
                crypted_password = encrypt_password(password)
                run_command(f"usermod -p {crypted_password} {username}")
            else:
                print(f"Password already exists for user {username}")
        else:
            password = os.getenv("PASSWD")
            crypted_password = encrypt_password(password)
            if secondary_group:
                group_join = ",".join(secondary_group)
                run_command(f"useradd -m -s /bin/bash -g {primary_group} -G {group_join} -p {crypted_password} {username}")
            else:
                run_command(f"useradd -m -s /bin/bash -g {primary_group} -p {crypted_password} {username}")
            print("User added.")


if __name__ == "__main__":
    create_users()
