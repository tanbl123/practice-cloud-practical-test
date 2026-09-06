# Module 10 — Implementing Monitoring, Elasticity, and High Availability

**Status:** not started | **Confidence:** – (Knowledge Check: 100/100)
**PRIORITY MODULE — the ALB + ASG build is a classic practical task.**

## Scope
Load balancing, automatic scaling, monitoring, and disaster recovery planning.

## Key concepts to know cold
- **Elastic Load Balancing types:**
  - **ALB** — Layer 7 (HTTP/HTTPS), path- and host-based routing, target groups,
    WebSockets. Default choice for web apps.
  - **NLB** — Layer 4 (TCP/UDP), ultra-low latency, static IP / Elastic IP,
    millions of requests/sec.
  - **GWLB** — for third-party virtual appliances (firewalls/IDS).
- **Components:** listener (port/protocol) → rules → **target group** (with a
  **health check**) → registered targets. Cross-zone load balancing spreads
  traffic evenly across AZs.
- **The load balancer needs subnets in at least two AZs** to be highly available.
- **Auto Scaling Group (ASG):** **launch template** (what to launch) +
  min / desired / max capacity + subnets across multiple AZs.
  - **Scaling policies:** **target tracking** (keep CPU at 50% — the usual
    right answer), step scaling, simple scaling, **scheduled** (predictable
    load), predictive.
  - **Health check types:** EC2 (hardware) or **ELB** (application-aware —
    choose this so a failed app is replaced, not just a failed instance).
  - **Health check grace period:** stops the ASG killing instances that are
    still booting/bootstrapping.
  - **Cooldown:** prevents rapid repeated scaling actions.
- **CloudWatch:** metrics (5-min basic, 1-min detailed), **alarms**
  (OK / ALARM / INSUFFICIENT_DATA), dashboards, **Logs** (needs the CloudWatch
  agent for OS-level metrics like memory and disk — these are **not** default
  EC2 metrics), Events/EventBridge.
- **SNS:** notification topic, subscriptions — how an alarm reaches a human.
- **Route 53 routing policies:** simple, weighted, latency, failover,
  geolocation, multivalue — plus health checks for DNS-level failover.
- **DR strategies** (backup & restore → pilot light → warm standby →
  multi-site), **RTO** and **RPO**: these belong to **Module 16, Planning for
  Disaster — outside the test scope**. Know the vocabulary in case it is
  referenced, but do not spend revision time here.

## Typical AWS Academy lab
Building a **highly available web application**: launch template, Auto Scaling
group across two AZs, an Application Load Balancer with a target group and
health checks, a CloudWatch alarm, then load-testing to watch it scale out.

## High-yield gotchas (marks lost here)
- ALB in one AZ only = not highly available. **Select at least two subnets in
  two different AZs** — for both the ALB and the ASG.
- The ALB's security group must allow inbound 80/443 from the internet, and the
  **instance security group must allow traffic from the ALB's security group**
  (not from 0.0.0.0/0). This SG-referencing-SG pattern is heavily marked.
- Health check path must actually return HTTP 200 (`/index.html`, not `/health`
  unless that page exists) — otherwise targets stay "unhealthy" and the ALB
  serves 502/503.
- Memory and disk utilisation are **not** default CloudWatch metrics.
- Scaling is driven by the ASG, **not** by the load balancer.
- Set ASG **min ≥ 2 across 2 AZs** for HA; min=1 is not highly available.

## Self-check questions
1. Draw/describe request flow: user → ? → ? → ? → EC2.
2. Targets show "unhealthy" but the app works when you hit the instance IP directly. Why?
3. Target tracking vs scheduled scaling — one scenario for each.
5. Which two security group rules make an ALB + EC2 tier work correctly?

## My notes
_(fill in as we go)_

---

# Confirmed lab: Creating a Highly Available Environment

*(Module 10 guided lab, ~40 min. This is the flagship build for the module.)*

## Request flow to be able to draw from memory
```
Internet
   |
[Internet Gateway]
   |
Application Load Balancer  ── PUBLIC subnets, 2 AZs   (SG: HTTP/HTTPS from 0.0.0.0/0)
   |  forwards to target group "Inventory-App"
   v
EC2 instances in Auto Scaling group ── PRIVATE subnets, 2 AZs
   |                                    (SG: HTTP:80 from the ALB's SG)
   v
RDS inventory-db ── PRIVATE subnet     (SG: 3306 from the app SG)
```

## Build order
1. **Inspect the VPC** — 10.0.0.0/16, public+private subnets in 2 AZs, IGW, one
   NAT gateway, RDS in a private subnet.
2. **Application Load Balancer** `Inventory-LB` — **Lab VPC**, both **public**
   subnets, new SG `Inventory-LB` (HTTP + HTTPS from Anywhere-IPv4), target
   group `Inventory-App` (Instances, healthy threshold 2, interval 10s).
3. **AMI** `Web Server AMI` from the running `Web Server 1`.
4. **Launch template** `Inventory-LT` — My AMIs → Web Server AMI, t2.micro,
   key pair `vockey`, SG `Inventory-App`, IAM instance profile
   `Inventory-App-Role`, **detailed CloudWatch monitoring on**, user data script.
5. **Auto Scaling group** `Inventory-ASG` — Lab VPC, **both PRIVATE subnets**,
   attach to existing target group `Inventory-App`, **ELB health checks on**,
   **grace period 90 s**, group metrics on, **desired 2 / min 2 / max 2**,
   no scaling policies, tag Name=Inventory-App.
6. **Three-tier security groups** (see below).
7. **Test** — ALB DNS name, refresh toggles between instances.
8. **Test HA** — terminate one instance; site stays up; ASG replaces it.

## The three-tier security group chain — HEAVILY MARKED
| Tier | Security group | Inbound rule |
|---|---|---|
| Load balancer | `Inventory-LB` | HTTP + HTTPS from **Anywhere-IPv4** |
| Application | `Inventory-App` | HTTP :80 from **sg `Inventory-LB`** |
| Database | `Inventory-DB` | MySQL 3306 from **sg `Inventory-App`** (delete the old 10.0.0.0/16 rule) |

Each tier accepts traffic **only from the tier above**, and the source is
**another security group, not a CIDR**. Chaining security groups this way is the
single most examinable idea in this lab: the rule keeps working as instances are
added and removed, because it names a group rather than addresses.

## Why each setting exists
- **ALB in two public subnets / ASG in two private subnets** — this is what makes
  it highly available. One AZ is not HA.
- **ELB health checks** (not EC2 health checks) — EC2 checks only detect a dead
  instance; ELB checks detect a dead *application* and let the ASG replace it.
- **Health check grace period 90 s** — the user data script installs Apache and
  the app on boot. Without the grace period the ASG would kill instances before
  they finish bootstrapping, in a loop.
- **Detailed monitoring + group metrics (1-minute)** — lets scaling react fast;
  the default is 5-minute granularity.
- **min = max = desired = 2** — no scaling policies in this lab; the ASG is used
  purely for **self-healing / availability**, not elasticity.
- **Instances have no public IP** — users only ever reach the load balancer.
- **HTTPS terminates at the ALB** and is forwarded as HTTP, so the app SG needs
  port 80 only. This is **TLS offloading**.

## Traps
- **"VPC: Lab VPC" is NOT the default selection** on the load balancer page —
  the lab warns about this explicitly. Getting it wrong wastes the whole build.
- The lab text says the settings keep "2-6 instances running" but the steps say
  min 2 / max 2. **Follow the steps (2/2/2)** — the 2-6 wording is stale.
- Target group must be created with **Lab VPC** too.
- Remember to remove the **default security group** from the ALB, leaving only
  `Inventory-LB`.
- The DB rule from `10.0.0.0/16` must be **deleted**, not just supplemented.

## Optional tasks are the real HA lesson
- **RDS Multi-AZ** — "Create a standby instance". The standby serves no traffic;
  it exists for automatic failover. The app keeps using the same DNS endpoint.
- **Second NAT gateway** — the starting architecture has **one NAT gateway in one
  AZ**, which is a single point of failure for outbound traffic from private
  subnet 2. Fix: a NAT gateway **per AZ**, plus a **separate route table per
  private subnet** pointing at the NAT gateway in its own AZ.
  This is the classic "what is still not highly available?" exam question.

## Self-check questions
1. Trace a request from browser to database, naming every hop and its subnet.
2. Which two security group rules define the app tier, and why groups not CIDRs?
3. Why 90 seconds of grace period?
4. ELB vs EC2 health check — which and why?
5. The ALB and ASG span two AZs. What is still a single point of failure?
