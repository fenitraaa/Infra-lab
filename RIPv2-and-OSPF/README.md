# Routing Information Protocol (RIPv2) and Open Shortest Path First (OSPF)

---

## Overview

This project presents the steps for implementing and analyzing the RIPv2 and OSPF routing protocols in a simulated environment using GNS3. The objective is to configure, observe, compare, and redistribute routes between the two protocols, while documenting the results and network behavior.

![Full network topology](images/init-topo-Capture%20d’écran%20du%202025-05-10%2011-43-04.png)

---

## Part 1: RIPv2

### 1. Topology

The network topology was built according to the project specifications, with 6 routers (R1 to R6) interconnected using the [Cisco c7200](https://github.com/fenitraaa/Infra-lab/raw/main/RIPv2-and-OSPF/c7200-adventerprisek9-mz.152-4.M7.bin) model.

![RIPv2 topology in GNS3](images/init-rip-Capture%20d’écran%20du%202025-05-10%2020-23-18.png)

---

### 2. Addressing Plan and Configuration

Each router interface was assigned an IP address from the `192.168.x.0/29` subnets.

![R1 configuration](images/R1-Capture%20d’écran%20du%202025-05-29%2020-09-00.png)

![R2 configuration](images/R2-Capture%20d’écran%20du%202025-05-29%2020-10-36.png)

![R3 configuration](images/R3-Capture%20d’écran%20du%202025-05-29%2020-12-02.png)

![R4 configuration](images/R4-Capture%20d’écran%20du%202025-05-29%2020-13-13.png)

![R5 configuration](images/R5-Capture%20d’écran%20du%202025-05-29%2020-14-12.png)

![R6 configuration](images/R6-Capture%20d’écran%20du%202025-05-29%2020-15-56.png)

---

### 3. Enabling RIP Version 2

RIPv2 was activated on all routers with `no auto-summary` to allow subnet-level advertisement.

![RIPv2 activation on all routers](images/R1-rip-Capture%20d’écran%20du%202025-05-29%2020-17-18.png)
![](images/R2-rip-Capture%20d’écran%20du%202025-05-29%2020-18-21.png)
![](images/R3-rip-Capture%20d’écran%20du%202025-05-29%2020-19-25.png)
![](images/R4-rip-Capture%20d’écran%20du%202025-05-29%2020-20-05.png)
![](images/R5-rip-Capture%20d’écran%20du%202025-05-29%2020-21-53.png)

---

### 4. Routing Table Analysis and Connectivity Tests

After convergence, all remote subnets appeared in each router's routing table marked `R` (RIP-learned).

![R1 routing table](images/R1-routing-tables-Capture%20d’écran%20du%202025-05-29%2023-23-00.png)

![Ping results](images/R1-ping-Capture%20d’écran%20du%202025-05-29%2023-20-25.png)

---

### 5. Network Resilience Test (Link Failure)

The link between R2 and R3 was shut down to simulate a failure. RIPv2 automatically rerouted traffic through an alternate path.

![Ping results after link failure](images/ping-failure-Capture%20d’écran%20du%202025-05-29%2020-36-58.png)

---

### 6. Protocols and Ports Used by RIP

RIP uses **UDP on port 520** for both sending and receiving routing updates.

---

### 7. Observing RIP Traffic with Wireshark

After re-enabling the R2–R3 link, RIP traffic was captured with Wireshark. The metric of 4 reflects the hop count to reach 192.168.2.0 via the alternate path after link restoration.

![Wireshark RIP capture after link restore — Metric 4](images/RIP-wireshark-Capture%20d’écran%20du%202025-05-29%2020-59-28.png)

---

### 8. Network Behavior After Removing R2

R2 was removed from the topology to observe how RIPv2 handles complete router loss. A metric of 16 indicates the route is unreachable.

![Wireshark RIP metric 16](images/Remove-R2-metric16-Capture%20d’écran%20du%202025-05-14%2016-45-34.png)

**Reconvergence timeline observed in Wireshark:**

| Packet | Time | Event |
|--------|------|-------|
| #15 | 85s | Route to R3 becomes unreachable (metric 16) |
| #23 | 142s | R1 receives a new valid route to R3 |

**Reconvergence time: 142s - 85s = 57 seconds**

> R1 took 57 seconds to find a working path to R3 after the R2–R3 link was cut.

![Wireshark reconvergence timeline](images/Reconvergence-time-Capture%20d’écran%20du%202025-05-29%2021-12-41.png)

---

## Part 2: OSPF

### 1. Adding Loopback Interfaces

A loopback interface was configured on each OSPF router to serve as a stable Router ID (RID).

![Loopback configuration on R7, R8, R9](images/R7-Capture%20d’écran%20du%202025-05-29%2021-56-26.png)
![](images/R8-Capture%20d’écran%20du%202025-05-29%2021-57-27.png)
![](images/R9-Capture%20d’écran%20du%202025-05-29%2021-59-32.png)

---

### 2. Addressing Plan and OSPF Configuration
R7:

![R7 OSPF configuration](images/R7-ospf(1)-Capture%20d’écran%20du%202025-05-29%2022-01-49.png)
![](images/R7-ospf(2)-Capture%20d’écran%20du%202025-05-29%2010-44-21.png)

R8:

![R8 OSPF configuration](images/R8-ospf-Capture%20d’écran%20du%202025-05-29%2022-15-38.png)
![](images/R8-ospf(2)-Capture%20d’écran%20du%202025-05-29%2010-42-39.png)

R9:

![R9 OSPF configuration](images/R9-ospf-Capture%20d’écran%20du%202025-05-29%2022-18-28.png)
![](images/R9-ospf(2)-Capture%20d’écran%20du%202025-05-29%2010-45-27.png)
---

### 3. OSPF Message Exchange

OSPF relies on several message types to establish and maintain communication between routers:

| Message | Description |
|---------|-------------|
| **Hello** | Sent on startup to discover neighbors and establish adjacencies |
| **Database Description (DBD)** | Exchanged to summarize each router's link-state database |
| **Link-State Request (LSR)** | Sent when a router detects missing information |
| **Link-State Update (LSU)** | Response containing the requested link-state information |
| **Link-State Acknowledgment (LSAck)** | Confirms receipt of each update |

![OSPF Hello packet in Wireshark](images/Hello-packet-Capture%20d’écran%20du%202025-05-29%2022-21-01.png)

---

### 4. Router Identifiers (RID)

The loopback interface IP address is used as the Router ID because it is considered more stable than a physical interface address.

| Router | RID |
|--------|-----|
| R7 | 1.1.1.1 |
| R8 | 2.2.2.2 |
| R9 | 3.3.3.3 |

![OSPF RID verification](images/R7-rid-Capture%20d’écran%20du%202025-05-29%2022-37-44.png)
![](images/R8-rid-Capture%20d’écran%20du%202025-05-29%2022-37-51.png)
![](images/R9-rid-Capture%20d’écran%20du%202025-05-29%2022-38-01.png)

---

### 5. Connectivity Tests

![OSPF connectivity tests](images/R7-ping-Capture%20d’écran%20du%202025-05-29%2010-48-18.png)
![](images/R9-ping-Capture%20d’écran%20du%202025-05-29%2010-47-45.png)

---

### 6. Route Redistribution Between RIP and OSPF

R4 acts as the boundary router between the RIPv2 and OSPF domains. New interfaces were added to connect both domains.

New interface configuration on R4 and R7:
![New interface configuration on R4 and R7](images/R4-new-interface-Capture%20d’écran%20du%202025-05-29%2023-01-05.png)
![](images/R7-new-interface-Capture%20d’écran%20du%202025-05-29%2023-02-39.png)

OSPF activation on new interfaces:
![OSPF activation on new interfaces](images/R4-enable-ospf-Capture%20d’écran%20du%202025-05-29%2023-07-13.png)
![](images/R7-enable-ospf-Capture%20d’écran%20du%202025-05-29%2023-06-27.png)

**Observation before redistribution:**

R4 can ping R8's loopback (2.2.2.2) — success, because R4 already has an OSPF interface:
![Ping tests before redistribution](images/R4-ping-Capture%20d’écran%20du%202025-05-29%2023-12-28.png)

R8 cannot ping R4's interface connected to R3 — OSPF does not know RIP routes by default:
![](images/R8-ping(1)-Capture%20d’écran%20du%202025-05-29%2023-16-40.png)

R1 cannot ping R8, and R8 cannot ping R1 until redistribution is configured:
![](images/R1-ping-Capture%20d’écran%20du%202025-05-29%2023-20-25.png)
![](images/R8-ping(2)-Capture%20d’écran%20du%202025-05-29%2023-20-20.png)


**Routing tables of R1, R4, R8 before redistribution:**

![R1 routing table before redistribution](images/R1-routing-tables-Capture%20d’écran%20du%202025-05-29%2023-23-00.png)

![R4 routing table before redistribution](images/R4-routing-tables-Capture%20d’écran%20du%202025-05-29%2023-25-11.png)

![R8 routing table before redistribution](images/R8-routing-tables(1)-Capture%20d’écran%20du%202025-05-29%2023-24-29.png)

#### Redistributing RIP into OSPF (on R4)

![RIP into OSPF redistribution on R4](images/R4-redistributing-rip-Capture%20d’écran%20du%202025-05-29%2023-28-08.png)
After redistribution, a route toward R1 appears in R8's routing table.

![R8 routing table after RIP into OSPF redistribution](images/R8-routing-tables(2)-Capture%20d’écran%20du%202025-05-29%2023-32-23.png)

#### Redistributing OSPF into RIP (on R4)

R8 and R1 still cannot reach each other until OSPF is redistributed into RIP. A metric value must be specified during redistribution, otherwise routes do not propagate to RIP routers.

![OSPF into RIP redistribution on R4](images/R4-redistributing-ospf-Capture%20d’écran%20du%202025-05-29%2023-41-40.png)

---

### 7. Final Connectivity Tests and Verifications

Tests of connectivity after complete redistribution.
The OSPF networks do not yet appear on the RIP routers because there was an issue with the command.
To fix the problem, the metric must be specified when redistributing OSPF at the R4 level.

![](images/R4-redistributing-opsf-metric2-Capture%20d’écran%20du%202025-05-29%2023-53-39.png)

After complete redistribution, all routers across both domains can communicate.

Example: ping from R9 to the Ethernet1/1 interface of R6

![Final ping test R9 to R6](images/R9-ping-Capture%20d’écran%20du%202025-05-30%2000-01-36.png)

---

### 8. Final Topology

The complete topology after full configuration, showing both the RIPv2 and OSPF domains connected via R4.

| Domain | Routers | Subnets |
|--------|---------|---------|
| RIPv2 | R1, R2, R3, R4, R5, R6 | 192.168.1.0 – 192.168.6.0 /29 |
| OSPF | R4, R7, R8, R9 | 192.168.7.0 – 192.168.10.0 /29 |

> R4 is the boundary router that handles redistribution between both routing domains.

![Final topology after full configuration](images/TOPO.png)