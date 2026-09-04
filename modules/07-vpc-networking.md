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
