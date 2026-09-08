# Module 7 — Creating a Networking Environment (VPC)

**Status:** not started | **Confidence:** –
**PRIORITY MODULE — underpins Modules 8 and 10.**

## Scope
Building an isolated network: subnets, routing, gateways, and network security.

## Key concepts to know cold
- **VPC:** logically isolated network in one Region, defined by a CIDR block
  (/16 to /28). Spans all AZs in the Region.
- **Subnet:** lives in exactly **one AZ**, carved from the VPC CIDR.
  - **Public subnet** = its route table has a route `0.0.0.0/0 → Internet Gateway`.
  - **Private subnet** = no route to the IGW.
  - That routing rule is the *only* thing that makes a subnet "public".
- **AWS reserves 5 IP addresses per subnet** (network, VPC router, DNS, future
  use, broadcast). A /24 gives you 251 usable, not 256.
- **Internet Gateway (IGW):** one per VPC, horizontally scaled, enables
  **bidirectional** internet traffic.
- **NAT Gateway:** lets **private** subnet instances make **outbound** internet
  connections (e.g. yum update) while blocking inbound. Must be placed in a
  **public** subnet, needs an **Elastic IP**, and is AZ-specific (one per AZ
  for HA). Private subnet route: `0.0.0.0/0 → nat-xxxx`.
- **Route tables:** every subnet is associated with exactly one; the **main**
  route table applies if you don't explicitly associate a custom one. The
  `local` route for the VPC CIDR is always present and cannot be removed.
- **Security Group vs NACL** — classic exam table:

| | Security Group | Network ACL |
|---|---|---|
| Level | Instance (ENI) | Subnet |
| State | **Stateful** | **Stateless** |
| Rules | Allow only | Allow **and** Deny |
| Evaluation | All rules together | **In number order, first match wins** |
| Default | Deny inbound / allow outbound | Default NACL allows all |

- **Stateless matters:** a NACL needs an outbound rule for **ephemeral ports
  (1024–65535)** to let response traffic back out.
- **VPC endpoints:** reach AWS services privately without an IGW.
  **Gateway endpoints** = S3 and DynamoDB only (route table entry, free).
  **Interface endpoints** (PrivateLink) = most other services (ENI, hourly cost).
- **VPC Flow Logs:** capture accepted/rejected traffic metadata for troubleshooting.

## Typical AWS Academy lab
Building a VPC from scratch: VPC CIDR, two public + two private subnets across
two AZs, an internet gateway, a NAT gateway, custom route tables with correct
associations, and security groups — then launching an instance to prove it works.

## High-yield gotchas (marks lost here)
- **Creating a route table is not enough — you must associate it with the subnet.**
  This is the single most common lost mark in this module.
- NAT Gateway placed in a *private* subnet does nothing. It goes in a **public** one.
- A public IP alone does not give internet access — you also need the IGW route.
- Overlapping CIDRs will block future VPC peering. Plan the address space first.
- Deleting a NAT Gateway does not release its Elastic IP (which still bills).
- Instances in different subnets of the same VPC can always reach each other via
  the `local` route — subject to security groups/NACLs.

## Troubleshooting drill: "my private instance can't reach the internet"
Check, in order: (1) NAT Gateway exists and is in a public subnet with an EIP;
(2) private subnet's route table has `0.0.0.0/0 → nat-xxxx`; (3) that route
table is actually **associated** with the private subnet; (4) security group
allows outbound; (5) NACL allows outbound **and** inbound ephemeral ports.

## Self-check questions
1. How many usable IPs in a /26 subnet?
2. What exactly makes a subnet "public"?
3. Give the full route table entries for a public and a private subnet.
4. NACL vs SG: which is stateless, and what does that force you to configure?
5. Why does a NAT Gateway need a public subnet?

## My notes
_(fill in as we go)_

---

## NAT gateway: Zonal vs Regional availability mode (console option)

AWS added a **Regional** availability mode for NAT gateways in **November 2025**,
so the console now asks Zonal or Regional. Course material predates it.

| | **Zonal** (classic) | **Regional** (new) |
|---|---|---|
| Scope | one AZ | whole VPC, expands/contracts across AZs |
| Public subnet | **required** | **not required** — standalone VPC resource |
| HA | build **one per AZ** + a route table per private subnet | automatic; AWS follows your workloads |
| Route tables | one target per AZ | **one ID referenced everywhere** |
| Sub-modes | – | **Automatic** (AWS manages IPs/AZs) or **Manual** (you do) |

### For the practical test: choose ZONAL
The course, the labs and the marking scheme assume the classic model. If a
scenario says *"make the NAT gateway highly available"*, the expected answer is
**a NAT gateway per AZ with separate route tables** — that routing knowledge is
what is being examined. "Use regional mode" may be more modern but does not
demonstrate it.

### Real-world choice
- New build, HA without the management → **Regional (automatic)**
- Must pin/control outbound public IPs (partner allowlists) → **Regional (manual)**
- Existing architecture / strict per-AZ separation → **Zonal**

Regional mode does not change *what* a NAT gateway does (outbound-only, still via
the IGW). It changes **who manages per-AZ redundancy** — you, or AWS.

Sources: AWS What's New (Nov 2025); VPC User Guide "Regional NAT gateways for
automatic multi-AZ expansion"; AWS Networking blog "Introducing Amazon VPC
Regional NAT Gateway".

---

# Confirmed lab: Challenge (Café) — Creating a VPC Networking Environment

*(Module 7 Challenge lab, 56 marks, ~90 min. **This is the closest thing to the
practical test** — scenario-driven, no step-by-step.)*

## Build order (matches `notes/build-order.md`)
| # | Do | Detail |
|---|---|---|
| 1 | **Public Subnet** | Lab VPC · `10.0.0.0/24` · AZ **a** |
| 2 | **Internet gateway** | create **AND attach to Lab VPC** (two actions) |
| 3 | **Route** | edit the VPC's existing (main) route table → `0.0.0.0/0` → IGW |
| 4 | **Bastion Host** | Amazon Linux 2023 · t2.micro · vockey · Public Subnet · **public IP enabled** · SG `Bastion Host SG` = SSH 22 from **My IP** |
| 5 | **Private Subnet** | `10.0.1.0/24` · **same AZ** as public |
| 6 | **NAT gateway** | `Lab NAT Gateway` · **in the PUBLIC subnet** · Allocate Elastic IP |
| 7 | **Private Route Table** | `0.0.0.0/0` → NAT · **ASSOCIATE with Private Subnet** ← most-missed |
| 8 | **Key pair** | `vockey2` |
| 9 | **Private Instance** | Private Subnet · vockey2 · **no public IP** · SG `Private Instance SG` = SSH 22 from **the Bastion Host SG** (a group, not a CIDR) |
| 10 | **SSH passthrough** | agent forwarding; `ssh -A ec2-user@<bastion-ip>` then `ssh ec2-user@<private-ip>` |
| 11 | **Test internet** | `ping 8.8.8.8` from the private instance — proves the NAT path |
| 12 | **Custom NACL** | `Lab Network ACL` on Lab VPC · allow all in/out · **associate with Private Subnet** |
| 13 | **Test Instance** | Public Subnet · SG `Test SG` = **All ICMP - IPv4** inbound |
| 14 | **Deny rule** | outbound DENY All ICMP-IPv4 to `<test-private-ip>/32` with a **LOWER rule number** than the allow-all rule |

## The three details that carry the marks
1. **Route table ASSOCIATION** with the private subnet — creating the route is
   not enough.
2. **`Private Instance SG` source = the Bastion Host security group**, not a
   CIDR. Chaining groups, exactly as in the three-tier pattern.
3. **NACL rule ordering.** NACLs are evaluated **in ascending rule number,
   first match wins**. If allow-all is rule 100, the deny must be numbered
   *below* 100 (e.g. 50) or it is never reached.

## Question answers
1. **Internet gateway** — gives the public subnet bidirectional internet
   access; it is what lets the bastion host be reached from the internet.
2. **The NAT gateway** (in the public subnet) plus the private route table's
   `0.0.0.0/0 → nat` route. Outbound only.
3. **No.** The private instance has no public IP and its subnet has no route to
   the IGW. It is reachable only through the bastion host.
4. **Security / least privilege.** Separate keys mean compromising the bastion
   does not grant access to the private instance, and SSH **agent forwarding**
   lets you use the second key without ever copying it onto the bastion.
5. **No.** `Private Instance SG` only allows **SSH 22** from the bastion SG.
   ICMP is not permitted, and security groups are **allow-only**, so the ping
   gets no reply.
6. **None — no rule is needed.** Security groups are **stateful**: the outbound
   ping automatically permits the return traffic. (A stateless **NACL** would
   need an explicit rule — which is exactly why the NACL deny in task 44 works.)

---

## Elastic IPs — who actually needs one (asked 2026-09-08)

**Rule of thumb: an Elastic IP is for a thing that needs a *fixed, public* IPv4
address of its own.** Most of an architecture does not.

| Component | Public IP? | Elastic IP? | Why |
|---|---|---|---|
| **Public NAT gateway** | Yes | **REQUIRED** | It rewrites the source address of outbound packets to its own address, so replies can find their way back. No EIP = no NAT. |
| Private NAT gateway | No | No | NAT between VPCs / on-prem, never to the internet. |
| **Internet gateway** | — | **No** | Not an addressable device — it is a VPC attachment, horizontally scaled and managed by AWS. |
| **ALB** | AWS-managed | **No** | You get a **DNS name**; the IPs behind it change. Always test/reference the DNS name. |
| **NLB** | AWS-managed | **Optional — one per AZ** | The *only* ELB that can take an EIP. Exam trigger: *"the load balancer needs a static IP"* → **NLB**, not ALB. |
| EC2 in a private subnet | No | No | Unreachable from the internet by design; outbound via NAT. |
| EC2 in a public subnet | Auto-assigned | Only if the address must **survive a stop/start**, or an external firewall whitelists it | The auto-assigned public IP is released on stop and a different one is issued on start. |
| RDS | No | No | Reached by its endpoint DNS name. |

Other things to remember:
- The NAT gateway create page has an **Allocate Elastic IP** button inline — you
  do not pre-create one in EC2 → Elastic IPs first.
- **Academy quota is typically 5 EIPs per Region.** "Address limit exceeded" in a
  later lab = go to **EC2 → Elastic IPs** and release leftovers from earlier labs.
- An **unassociated** EIP is the classic billing-waste exam answer. Since
  Feb 2024 AWS charges for **all** public IPv4 addresses, in use or not.
