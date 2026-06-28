import hvac
import os

def login():
    client = hvac.Client(
        url=os.environ.get("VAULT_ADDR"),
        token=os.environ.get("VAULT_TOKEN"),
        verify=os.environ.get("VAULT_CACERT", True)
    )
    if not client.is_authenticated():
        raise PermissionError ("Vault athentification error")
    return client

def enable_engine(client):
    try:
        client.sys.enable_secrets_engine(
            backend_type="database",
            path="database"
        )
    except hvac.exceptions.InvalidRequest as e:
        if "path is already in use" in str(e):
            print("Database engine already enabled.")
        else:
            raise
    print("Database engine enabled.")

def configure_connection(client):
    client.write(
        "database/config/preserve",
        plugin_name="postgresql-database-plugin",
        allowed_roles="preserve-role",
        connection_url="postgresql://{{username}}:{{password}}@192.168.10.10:5432/preserve?sslmode=require",
        username="vault_admin",
        password=os.environ.get("PASSWORD")
    )
    print("PostgreSQL connection configured.")


def configure_role(client):
    client.write(
        "database/roles/preserve-role",
        db_name="preserve",
        creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
        default_ttl="1h",
        max_ttl="24h"
    )
    print("Role preserve-role configured.")

if __name__ == "__main__":
    client = login()
    enable_engine(client)
    configure_connection(client)
    configure_role(client)
