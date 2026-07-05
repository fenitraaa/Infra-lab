import hvac
import os


def login():
    client = hvac.Client(
        url=os.environ.get("VAULT_ADDR"),
        token=os.environ.get("VAULT_TOKEN"),
        verify=os.environ.get("VAULT_CACERT", True)
    )
    if not client.is_authenticated():
        raise PermissionError("Vault authentication error")
    return client


def enable_kubernetes_auth(client):
    try:
        client.sys.enable_auth_method(method_type="kubernetes")
        print("Kubernetes auth method enabled.")
    except hvac.exceptions.InvalidRequest as e:
        if "path is already in use" in str(e):
            print("Kubernetes auth method already enabled.")
        else:
            raise

def configure_kubernetes_auth(client):
    with open(os.environ.get("K3S_CA_CERT")) as f:
        ca_cert = f.read()
    with open(os.environ.get("K3S_SA_TOKEN")) as f:
        sa_token = f.read().strip()
    client.auth.kubernetes.configure(
        kubernetes_host="https://192.168.10.30:6443",
        kubernetes_ca_cert=ca_cert,
        token_reviewer_jwt=sa_token,
        disable_iss_validation=True,
    )
    print("Kubernetes auth method configured.")

def create_policy(client):
    policy = """
path "database/creds/preserve-role" {
  capabilities = ["read"]
}
path "sys/leases/renew" {
  capabilities = ["update"]
}
path "sys/leases/revoke" {
  capabilities = ["update"]
}
"""
    client.sys.create_or_update_policy(
        name="preserve-db-policy",
        policy=policy,
    )
    print("Policy preserve-db-policy created.")


def create_kubernetes_role(client):
    client.auth.kubernetes.create_role(
        name="preserve-role",
        bound_service_account_names=["preserve-api"],
        bound_service_account_namespaces=["prod"],
        policies=["preserve-db-policy"],
        ttl="1h",
    )
    print("Role preserve-role created.")

if __name__ == "__main__":
    client = login()
    enable_kubernetes_auth(client)
    configure_kubernetes_auth(client)
    create_policy(client)
    create_kubernetes_role(client)
