# Module 8 — Connecting Networks

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

# Confirmed lab: Creating a VPC Peering Connection

*(Course numbering confirmed 2026-09-04: this lab is Module 8.)*

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

---

## Run sheet — do-it checklist with verification points

Written 2026-09-04 for working through the lab live. Each task has a
**checkpoint**: if the checkpoint does not show what it should, stop and fix it
before moving on. Do not stack an error under another task.

### Before starting
- Lab VPC = `10.0.0.0/16` (app, public subnet) · Shared VPC = `10.5.0.0/16`
  (database, private subnet, **no internet gateway**).
- Do **not** change the lab Region.

### Task 1 — peering connection
- Peering connections → Create peering connection
- Name `Lab-Peer` · Requester **Lab VPC** · Accepter **Shared VPC**
- Actions → **Accept request**
- ✅ **Checkpoint:** status reads **Active** (not *Pending acceptance*).

### Task 2 — routes on BOTH sides
| Route table | Destination | Target |
|---|---|---|
| Lab Public Route Table | `10.5.0.0/16` | `Lab-Peer` (pcx-) |
| Shared-VPC Route Table | `10.0.0.0/16` | `Lab-Peer` (pcx-) |
- Destination is always the **other** VPC's CIDR. Clear stray check boxes before
  editing the second table — editing the wrong route table is easy here.
- ✅ **Checkpoint:** both tables show a `pcx-` route with status **Active**.

### Task 3 — flow logs on Shared VPC
- Your VPCs → **Shared VPC** → Flow logs tab → Create flow log
- Name `SharedVPCLogs` · Max aggregation interval **1 minute** ·
  Destination **CloudWatch Logs** · Log group `ShareVPCFlowLogs` ·
  IAM role `vpc-flow-logs-Role`
- ✅ **Checkpoint:** flow log appears with status **Active**. The log group may
  take a few minutes to exist — that is normal.

### Task 4 — test
- AWS Details → copy **EC2PublicIP** → open in a browser tab
- Settings → Endpoint = DB endpoint from AWS Details · Database `inventory` ·
  Username `admin` · Password `lab-password` → Save
- ✅ **Checkpoint:** inventory data displays. This proves peering works, because
  Shared VPC has no internet gateway.

### Task 5 — analyse
- CloudWatch log group `ShareVPCFlowLogs` → log stream `eni-*`
- Look for lines containing **3306**; expect **ACCEPT** and both directions.
- ✅ **Checkpoint:** you can point at a line and say which IP is the database,
  which is the app, and which direction it is.

### Finish
- **Submit** (top of lab instructions) → Yes. Check Grades. Submit again after
  any fix — the last submission counts.
- Then **End Lab**.

### If a checkpoint fails — troubleshoot in this order
1. Peering status **Active**? (a pending request routes nothing)
2. **Both** routes present, correct CIDR, target `pcx-`?
3. DB security group allows **3306 from `10.0.0.0/16`**?
4. NACLs allow 3306 out and **ephemeral ports 1024-65535** back?
5. Endpoint and credentials typed correctly?

**Symptom tells you the layer:** a **hang/timeout** points at routing (often the
missing return route); **connection refused** or an application error points at
security groups, NACLs or credentials.
