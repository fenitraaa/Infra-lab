# High Availability Proxmox Cluster

## 1. Overview

This project sets up a Proxmox VE 9.2 high availability (HA) infrastructure in a virtualized lab environment (VirtualBox). It hosts a containerized web application.

## 2. Architecture

![Architecture](<proxmox-HA.png>)

## 3. Implementation steps

### 3.1 Installing Proxmox VE

Booting the Proxmox VE 9.2 ISO in a VirtualBox virtual machine.

![Proxmox installer boot menu](<screenshot/Screenshot 2026-10-03 101055.png>)

Starting the installation (partition creation) on the `proxmox-lab` VM.

![Proxmox VE installer in progress](<screenshot/Screenshot 2026-10-04 000030.png>)

After installation, the console shows the administration URL (`https://10.0.2.15:8006/`).

![Proxmox console after installation](<screenshot/Screenshot 2026-10-04 113510.png>)

The web interface is reachable from the host machine via `https://localhost:8006` (VirtualBox port forwarding), logging in as `root` (Linux PAM).

![Proxmox VE login page](<screenshot/Screenshot 2026-10-04 113559.png>)

### 3.2 First LXC container (`node-1`) and Docker

An Ubuntu 24.04 LTS LXC container (`101 – node-1`) is created on the `pve` node.

![Console of container 101 node-1](<screenshot/Screenshot 2026-10-11 094626.png>)

Docker (`docker-ce`, `containerd`, `buildx` and `compose` plugins) is installed in it.

![Docker installation in node-1](<screenshot/Screenshot 2026-10-11 102510.png>)

The LXC container creation wizard (unprivileged container, Nesting option enabled, which is required to run Docker inside an LXC):

![LXC container creation wizard](<screenshot/Screenshot 2026-10-11 171021.png>)

### 3.3 The three virtual machines of the cluster

Three Proxmox VMs (`pve1`, `pve2`, `pve3`) run in VirtualBox.

![VirtualBox manager with pve1, pve2, pve3](<screenshot/Screenshot 2026-10-11 170722.png>)

### 3.4 Creating the cluster and the QDevice

The `lab-HA` cluster is formed: `pve2` joins `pve1` (192.168.100.10) through the Cluster Join wizard (assisted join, fingerprint verified).

![Cluster Join on pve2](<screenshot/Screenshot 2026-10-11 150642.png>)

A 2-node cluster cannot keep quorum if one node goes down. So we add an external vote (QDevice) on `pve3`:

- Installing `corosync-qnetd` on `pve3`:

![Installing corosync-qnetd on pve3](<screenshot/Screenshot 2026-10-11 150207.png>)

- Installing `corosync-qdevice` on `pve1` and `pve2`:

![Installing corosync-qdevice on pve1](<screenshot/Screenshot 2026-10-11 150223.png>)

![Installing corosync-qdevice on pve2](<screenshot/Screenshot 2026-10-11 150457.png>)

- Allowing `root` SSH login on `pve3` (required to configure the QDevice):

![sshd configuration on pve3](<screenshot/Screenshot 2026-10-11 150353.png>)

- Checking the `corosync-qnetd` service (active):

![corosync-qnetd status](<screenshot/Screenshot 2026-10-11 150417.png>)

- Configuring from `pve1` with `pvecm qdevice setup 192.168.100.12`:

![pvecm qdevice setup](<screenshot/Screenshot 2026-10-11 150803.png>)

Result: 3 expected votes, quorum = 2, `Quorate Qdevice` flag. The cluster survives the loss of one node.

![Quorum with QDevice](<screenshot/Screenshot 2026-10-11 150849.png>)

### 3.5 Deploying the AI Weather application

In `node-1`, the front end is started with Docker, exposed on port 8080 and with `--restart always`:

```bash
docker run -d --name aiweather --restart always -p 8080:80 ghcr.io/fenitraaa/aiweather-front:latest
```

![Starting the aiweather container](<screenshot/Screenshot 2026-10-11 155630.png>)

The application shows today's weather (temperature, precipitation, wind), a 7-day forecast, a history and a prediction chart. It is accessible at `aiweather.test:8080`.

![AI Weather application](<screenshot/Screenshot 2026-10-11 171549.png>)

### 3.6 Network access: NAT and load balancer

On `pve1` and `pve2`, IP forwarding is enabled and traffic arriving on port 8080 is redirected (DNAT) to the container `10.0.2.50:8080`, with MASQUERADE. This way, whichever node hosts the container, the service stays reachable on the node's IP.

```bash
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forward.conf
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 8080 -j DNAT --to-destination 10.0.2.50:8080
iptables -t nat -A POSTROUTING -d 10.0.2.50 -p tcp --dport 8080 -j MASQUERADE
```

![NAT on pve1](<screenshot/Screenshot 2026-10-11 160943.png>)

![NAT on pve2](<screenshot/Screenshot 2026-10-11 160815.png>)

Test from `pve3`: the service answers `HTTP/1.1 200 OK` (Nginx server) on `192.168.100.10:8080`.

![curl test from pve3](<screenshot/Screenshot 2026-10-11 161640.png>)

HAProxy is installed on `pve3` to act as a single entry point and distribute/redirect traffic to the active node.

![HAProxy installation](<screenshot/Screenshot 2026-10-11 161707.png>)

![HAProxy service active](<screenshot/Screenshot 2026-10-11 161730.png>)

### 3.7 Making the container highly available

CT 101 is added as an HA resource (requested state `started`, 1 restart max, 1 relocation max, failback and auto-rebalance enabled). Proxmox reminds that at least three quorum votes are recommended, hence the value of the QDevice.

![Adding CT 101 to HA resources](<screenshot/Screenshot 2026-10-11 153101.png>)

The HA status confirms: quorum OK, fencing armed (CRM watchdog active), master `pve1`, `ct:101` started on `pve1`.

![Datacenter HA status](<screenshot/Screenshot 2026-10-11 171631.png>)

### 3.8 ZFS storage and replication

Two 20 GB virtual disks are created in VirtualBox for `pve1` and `pve2`.

![Creating the VDI disks](<screenshot/Screenshot 2026-10-11 192123.png>)

On each node, a ZFS pool `zfs-data` is created on `/dev/sdb` (`ashift=12`, `lz4` compression). On `pve2`, the maximum ARC cache size is limited to 512 MB (`zfs_arc_max=536870912`) to save the VM's memory.

![ZFS pool on pve1](<screenshot/Screenshot 2026-10-11 195347.png>)

![ZFS pool on pve2](<screenshot/Screenshot 2026-10-11 195709.png>)

The pool is declared as Proxmox storage on both nodes (content `rootdir,images`); `pvesm status` lists `local`, `local-lvm`, `nfs-shared` and `zfs-data`.

![Adding the zfs-data storage](<screenshot/Screenshot 2026-10-11 195830.png>)

A replication job for CT 101 to `pve2` is created, every 15 minutes.

![Creating the replication job](<screenshot/Screenshot 2026-10-11 200436.png>)

`pvesr status` confirms it works correctly (state OK, 0 failures).

![Replication status](<screenshot/Screenshot 2026-10-11 200545.png>)

## 4. Failover test

To simulate a failure, the `pve1` VM is abruptly powered off from VirtualBox.

![Powering off pve1 in VirtualBox](<screenshot/Screenshot 2026-10-11 202815.png>)

Result observed on `pve2`: `pve1` is detected as dead, `pve2` becomes HA master, and the `ct:101` service is automatically restarted on `pve2`. Quorum stays OK thanks to the QDevice.

![Failover: ct:101 restarted on pve2](<screenshot/Screenshot 2026-10-11 203346.png>)
