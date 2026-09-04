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
