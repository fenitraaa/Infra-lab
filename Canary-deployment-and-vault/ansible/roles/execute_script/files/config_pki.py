import hvac
import subprocess
import os

server_issue_cert = {
    "vault-1": "192.168.10.11",
    "db": "192.168.10.10",
    "vault-2": "192.168.10.12",
    "k3s": "192.168.10.30" }

def login():
    client = hvac.Client(
        url=os.environ.get("VAULT_ADDR"),
        token=os.environ.get("VAULT_TOKEN")
    )
    if not client.is_authenticated():
        raise PermissionError ("Vault athentification error")
    return client

def server_actif(server):
    server_ip = server_issue_cert.get(server)
    print(f"{server}: {server_ip} \n", end="")
    result = subprocess.run(["ping", "-c", "1", "-W", "1", server_ip], stdout=subprocess.DEVNULL)
    if result.returncode == 0:
        return True
    else:
        print(f"Server {server.swapcase()} inactif.")
        return False

def enable_pki_mode(client, path="pki", max_lease_ttl="87600h"):
        try:
            client.sys.enable_secrets_engine(
                backend_type="pki",
                path=path
            )
        except hvac.exceptions.InvalidRequest as e:
            if "path is already in use" in str(e):
                print("PKI engine already enabled.")
            else:
                raise

        try:
            client.sys.tune_mount_configuration(
                path=path,
                max_lease_ttl=max_lease_ttl
            )
            print(f"TTL for {path} configured successfully.")
        except hvac.exceptions.InvalidRequest as e:
            print(f"Error when enabling pki engine : {e}")

def generate_ca(client):
    response = client.secrets.pki.read_ca_certificate(mount_point="pki")
    if response:
        print("Root CA already exists, skipping.")
        return response
    else:
        response = client.secrets.pki.generate_root(
            type="internal",
            common_name="Vault Lab CA",
            extra_params={"ttl": "87600h"}
        )
        cert = response["data"]["certificate"]
        with open("/tmp/ca.crt", "w") as f:
            f.write(cert)
        print("Root CA generated and saved to /tmp/ca.crt")
        print("[+] Ca.crt genereted.\n")
        return cert

def configure_urls(client):
    client.secrets.pki.set_urls(
        params={
            "issuing_certificates": f"http://192.168.10.20:8200/v1/pki/ca/pem",
            "crl_distribution_points": f"http://192.168.10.20:8200/v1/pki/crl"
        },
        mount_point="pki"
    )
    client.secrets.pki.set_urls(
        params={
            "issuing_certificates": f"http://192.168.10.20:8200/v1/pki_int/ca/pem",
            "crl_distribution_points": f"http://192.168.10.20:8200/v1/pki_int/crl"
        },
        mount_point="pki_int"
    )
    print(f"PKI URLs configured with HAProxy address: 192.168.10.20")

def generate_csr_int(client):
    existing = client.secrets.pki.read_ca_certificate(mount_point="pki_int")
    if existing:
        print("Intermediate CA already exists, skipping.")
        return None 
    else:
        response = client.secrets.pki.generate_intermediate(
            type="internal",
            common_name="Vault Lab Intermediate CA",
            mount_point="pki_int"
        )
        csr = response["data"]["csr"]
        with open("/tmp/pki_int.csr", "w") as f:
            f.write(csr)
        print("Intermediate CSR generated and saved to /tmp/pki_int.csr")
        return csr

def sign_intermediate(client, csr):
    response = client.secrets.pki.sign_intermediate(
        csr=csr,
        common_name="Vault Lab Intermediate CA",
        extra_params={"ttl": "43800h"},
        mount_point="pki"
    )
    certificate = response["data"]["certificate"]
    issuing_ca  = response["data"]["issuing_ca"]
    full_chain = certificate + "\n" + issuing_ca
    with open("/tmp/pki_int_chain.crt", "w") as f:
        f.write(full_chain)
    print("Full chain saved to /tmp/pki_int_chain.crt")
    return full_chain

def set_signed_intermediate(client, certificate):
    client.secrets.pki.set_signed_intermediate(
        certificate=certificate,
        mount_point="pki_int"
    )
    print("Signed intermediate certificate imported into pki_int.")

def create_role(client):
    client.secrets.pki.create_or_update_role(
        name="lab-server",
        extra_params={
            "allowed_domains": "vault-1,vault-2,db,k3s",
            "allow_bare_domains": True,
            "allow_ip_sans": True,
            "max_ttl": "8760h",
        },
        mount_point="pki_int"
    )
    print(f"Role lab-server created on pki_int.")

def generate_cert_servers(client):
    certificates = {}
    for server, ip in server_issue_cert.items():
        if server_actif(server):
            response = client.secrets.pki.generate_certificate(
                name="lab-server",
                common_name=server,
                extra_params={
                    "ip_sans": ip,
                    "ttl": "8760h"
                },
                mount_point="pki_int"
            )
            certificates[server] = response["data"]
            print(f"Certificate generated for {server}.")
    return certificates

def save_certificates(certs):
    for server, cert in certs.items():
        os.makedirs(f"/tmp/certs/{server}", exist_ok=True)
        with open(f"/tmp/certs/{server}/{server}.crt", "w") as f:
            f.write(cert["certificate"])
        with open(f"/tmp/certs/{server}/{server}.key", "w") as f:
            f.write(cert["private_key"])
        print(f"Certificate and key for {server} saved succesfully.")

def main():
    client = login()
    print("== PKI ACTIVATION ==")
    enable_pki_mode(client, path="pki", max_lease_ttl="87600h")
    enable_pki_mode(client, path="pki_int", max_lease_ttl="43800h")
    print("[+] All PKI activated.\n")
    print("== CERTIFICATE GENERATION FOR ROOT ==")
    generate_ca(client)
    configure_urls(client)
    print("\n== CERTIFICATE GENERATION FOR INTERMEDIATE ==")
    csr = generate_csr_int(client)
    if csr:
        full_chain = sign_intermediate(client, csr)
        set_signed_intermediate(client, full_chain)
        print("[+] Intermediate certificate done .\n")
    else:
        pass
    print("\n== ROLE CREATION AND CERTIFICATE FOR ALL SERVER ==")
    create_role(client)
    certs = generate_cert_servers(client)
    save_certificates(certs)
    print("[+] Certificate and role created.\n")
if __name__ == "__main__":
    main()
