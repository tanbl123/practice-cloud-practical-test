# Module 9 — Implementing Elasticity, High Availability and Monitoring

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
- **DR strategies (increasing cost, decreasing RTO/RPO):** backup & restore →
  pilot light → warm standby → multi-site active/active.
  **RTO** = how long to recover. **RPO** = how much data you can afford to lose.

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
4. Define RTO and RPO, and place the four DR strategies on that scale.
5. Which two security group rules make an ALB + EC2 tier work correctly?

## My notes
_(fill in as we go)_
