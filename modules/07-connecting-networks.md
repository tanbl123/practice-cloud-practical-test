# Module 7 — Connecting Networks

**Status:** not started | **Confidence:** – (Knowledge Check: 100/100)

## Scope
Joining VPCs to each other and connecting AWS to on-premises networks.

## Key concepts to know cold
- **VPC Peering:** private one-to-one connection between two VPCs (same or
  different Region/account). **Not transitive** — if A↔B and B↔C, A cannot
  reach C. **CIDRs must not overlap.** Requires a route table entry **in both
  VPCs** plus security group rules.
- **Transit Gateway:** hub-and-spoke router connecting many VPCs and on-prem
  links. **Transitive** — solves the peering mesh problem (n VPCs need
  n(n-1)/2 peering connections; a TGW needs n attachments).
- **AWS Site-to-Site VPN:** IPsec tunnel over the **public internet**.
  Components: **Virtual Private Gateway (VGW)** on the AWS side +
  **Customer Gateway (CGW)** on your side. Two tunnels for redundancy.
  Quick to set up, cheap, but latency varies with the internet.
- **AWS Direct Connect (DX):** a **dedicated private physical connection**
  from your data centre to AWS. Consistent low latency, high bandwidth,
  reduced data transfer cost — but takes weeks to provision and costs more.
  Best practice: **DX with a VPN as backup**.
- **AWS PrivateLink / Interface endpoints:** expose a service privately into a
  VPC via an ENI, without peering or exposing the whole network.
- **VPN CloudHub:** connect multiple on-prem sites via the VGW.

## High-yield gotchas
- "Consistent, predictable latency / dedicated bandwidth" → **Direct Connect**.
  "Quick, cheap, encrypted over internet" → **Site-to-Site VPN**.
  "Many VPCs, avoid a mesh" → **Transit Gateway**.
- Peering routes must be added on **both sides** — a one-sided route is a
  classic half-mark loss.
- Peering is not transitive and does **not** support edge-to-edge routing
  (you cannot use a peer's IGW, NAT or VPN).

## Self-check questions
1. Five VPCs must all talk to each other. Peering or TGW — and how many connections?
2. Name the two endpoints of a Site-to-Site VPN.
3. Company needs a private link to AWS within 48 hours. What do you propose, and why not DX?
4. A↔B peered, B↔C peered. Can A reach C?

## My notes
_(fill in as we go)_

---

# ⚠️ NUMBERING CORRECTION (2026-09-04)

The user confirmed that the **"Creating a VPC Peering Connection" guided lab
sits under their course's Module 8**, not Module 7 as assumed in these notes.

**This means the module numbering in this repo may be off by one from Module 6
onward, and that matters:** if Connecting Networks is Module 8, then HA/
Elasticity may be Module 9 or 10, and **CloudFormation may fall outside the
Modules 1-10 test scope entirely**. Confirm the real module list from Canvas
before relying on the numbering in `modules/00-overview.md`.

---

# Confirmed lab: Creating a VPC Peering Connection (course Module 8)

**Duration:** ~30 min. **Status:** guided through with Claude on 2026-09-04.

## Lab setup
- **Lab VPC** `10.0.0.0/16` — inventory application on an EC2 instance in a
  **public** subnet.
- **Shared VPC** `10.5.0.0/16` — database instance in a **private** subnet,
  **no internet gateway**.
- CIDRs are deliberately non-overlapping, which is a hard requirement for peering.

## Task flow and what each step actually proves
1. **Create peering connection** `Lab-Peer` (Requester = Lab VPC,
   Accepter = Shared VPC), then **Accept request**.
   Status goes `Initiating request` → `Pending acceptance` → **`Active`**.
2. **Routes on BOTH sides** — this is what makes peering function:
   - Lab Public Route Table: `10.5.0.0/16` → `Lab-Peer` (pcx-)
   - Shared VPC Route Table: `10.0.0.0/16` → `Lab-Peer` (pcx-)
3. **Flow logs** on Shared VPC → CloudWatch Logs group `ShareVPCFlowLogs`,
   1-minute aggregation, using IAM role `vpc-flow-logs-Role`.
4. **Test:** configure the app's Settings with the DB endpoint,
   database `inventory`, user `admin`, password `lab-password`.
5. **Analyse** log stream `eni-*`, looking at **port 3306** entries.

## The key insight of this lab
Shared VPC **has no internet gateway**. So if the inventory app can read the
database at all, traffic can only have crossed the peering connection. That is
the proof, and it is the sentence to reproduce in an exam answer.

## Gotchas surfaced by this lab
- Peering does nothing until **both** route tables have a route. A one-sided
  route means the request arrives but the reply cannot get home — you see a
  **timeout**, not a connection refused.
- The peering request must be **accepted**; a pending connection routes nothing.
- The DB security group must allow **3306 from the Lab VPC CIDR**. Peering does
  not bypass security groups or NACLs.
- Flow logs need an **IAM role** whose trust policy allows
  `vpc-flow-logs.amazonaws.com` — a direct Module 8 (IAM) tie-in.
- Flow log entries take **several minutes** to appear. That is normal, not a fault.

## VPC Flow Log record format (default fields, in order)
```
version account-id interface-id srcaddr dstaddr srcport dstport
protocol packets bytes start end action log-status
```
- `protocol` **6 = TCP**, 17 = UDP, 1 = ICMP
- `action` = **ACCEPT** or **REJECT** (REJECT = a security group or NACL blocked it)
- `log-status` = OK / NODATA / SKIPDATA
- Flow logs capture **metadata only**, never packet contents.

## Traffic that flow logs do NOT capture
Instance metadata (`169.254.169.254`), Amazon Time Sync (`169.254.169.123`),
DHCP traffic, traffic to the Amazon-provided DNS server, traffic to the reserved
VPC router address, and traffic between an ENI and a Network Load Balancer ENI.
