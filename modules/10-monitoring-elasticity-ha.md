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

---

# Challenge (Café) lab: Creating a Scalable and Highly Available Environment for the Café

*(Module 10 challenge lab, ~90 min, 56 marks. **Unguided** — this is the closest
rehearsal you will get to the practical test. Do it without the run sheet open if
you can; use this file only when stuck.)*

## What is different from the guided "Highly Available Environment" lab
| | Guided lab | This challenge lab |
|---|---|---|
| ASG sizing | 2 / 2 / 2 | **desired 2 / min 2 / max 6** |
| Scaling policy | none | **target tracking, Average CPU = 25, warmup 60 s** |
| Order | ALB first, then ASG attaches to it | **ASG first with NO load balancer**, ALB after, then **attach the target group to the ASG** |
| NAT | already built | **you build the second NAT gateway yourself** |
| Test URL | `<ALB-DNS>` | **`<ALB-DNS>/cafe`** |

Those five differences are where the marks are. If you build it from muscle
memory of the guided lab you will lose points on every one of them.

## Build order (dependency order — do not reshuffle)

| # | Step | Checkpoint before moving on |
|---|---|---|
| 1 | **Inspect** VPC, subnets, route tables, CafeSG, CafeWebAppServer, AMIs | You can answer the six questions from what you saw, not from memory |
| 2 | **NAT gateway** in the **Public Subnet of the SECOND AZ**, Connectivity = Public, **Allocate Elastic IP** | State = Available (takes ~1–2 min) |
| 3 | **Route table for Private Subnet 2** → add `0.0.0.0/0` → **that new NAT gateway** | Route table shows 2 routes: `local` + `0.0.0.0/0 → nat-…`, **and the Subnet associations tab lists Private Subnet 2** |
| 4 | **Launch template** — AMI **Cafe WebServer Image** (My AMIs), t2.micro, **new key pair**, security group **CafeSG**, Resource tag `Name = webserver` applied to **Instances**, Advanced details → IAM instance profile **CafeRole** | Template version 1 created; re-open it and confirm the IAM profile and the tag actually saved |
| 5 | **Auto Scaling group** — that launch template, **Private Subnet 1 + Private Subnet 2**, **No load balancer**, desired 2 / min 2 / **max 6**, **target tracking: Average CPU utilization, target 25, instance warmup 60 s** | 2 instances launch and reach `InService` |
| 6 | **Application Load Balancer** — internet-facing, **both PUBLIC subnets**, **new security group** allowing **HTTP 80 from Anywhere-IPv4**, **new target group** (Instances, HTTP:80) | ALB state = Active; DNS name copied down |
| 7 | **Attach the target group to the ASG** — ASG → **Integrations / Load balancing → Edit → Application Load Balancer target groups → pick the new target group** | Target group → Targets tab shows the 2 ASG instances as **healthy** |
| 8 | **Test** `http://<ALB-DNS-name>/cafe` | Café menu page loads |
| 9 | **Stress test** via Session Manager on one instance | New instances appear in the ASG Activity tab |

## Step 7 is the single most-missed step
You created the ASG **before** the ALB existed, so the ASG has no idea the target
group exists. Creating a target group does **not** register anything. You must go
back into the ASG and attach it. If you skip this, the ALB has zero targets and
`<ALB-DNS>/cafe` returns **503 Service Unavailable** — and every "scaling works"
mark fails with it.

Symptom → cause map for this lab:
- **503** = target group empty (step 7 skipped) or all targets unhealthy.
- **504 / timeout** = routing or security group — the ALB cannot reach port 80 on
  the instance.
- **404 on `/`, works on `/cafe`** = normal. The café app is served from `/cafe`.
  If the **health check** is failing for the same reason, set the target group's
  health check path to **`/cafe`**.

## The stress test (Task: verify scaling)
Connect to one ASG instance with **Session Manager** (EC2 → Connect → Session
Manager — there is no SSH into a private subnet, and that is the point of
`CafeRole` on the launch template: SSM needs the instance profile).

```bash
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
stress --cpu 1 --timeout 600
```

Why this triggers a scale-out: t2.micro has **1 vCPU**, so `--cpu 1` pins that
instance to ~100%. The ASG metric is the **average across the group**, so with
two instances the average is ~50%, which is above the **25** target — the policy
adds instances until the average falls back to 25. That is why the target is set
low: it makes the demo fire quickly.

Watch it in **ASG → Activity** (scaling activity entries) and **Monitoring**.
Scale-in afterwards is slow (~15 min of low CPU) — do not wait for it.

## The six inspection questions — GRADED answers (submitted 2026-09-08)

| Q | Question | Correct answer |
|---|---|---|
| 1 | Which ports are open in CafeSG? | **VERIFY IN CONSOLE** — *not* "80 and 443" (marked wrong). Remaining options were "Port 80", "Ports 80, 443, and 3899", "Ports 22, 80, and 443". |
| 2 | Can you connect from the internet to instances in Public Subnet 1? | **Yes — if the instance has a public IP address, and the security group and network ACL allow it** ✔ |
| 3 | *Should* an instance in Private Subnet 1 reach the internet? | **Yes** ✔ |
| 4 | *Should* an instance in Private Subnet 2 reach the internet? | **No** |
| 5 | Can you connect to CafeWebAppServer from the internet? | **No** |
| 6 | Name of the AMI? | **Cafe WebServer Image** ✔ |

### THE LESSON (cost 3 marks)
**These questions describe the environment's CURRENT STATE, not the design
intent.** Despite the word *"should"*, Q3/Q4 are answered by reading the route
tables: Private Subnet 1 **has** a route to the existing NAT gateway (Yes);
Private Subnet 2 **has no NAT route** (No) — which is exactly the gap Task 2
tells you to fix.

**Q5 = No** is the one that reframes the whole lab: **CafeWebAppServer sits in a
private subnet** and is already unreachable from the internet. That is *why* you
build the ALB — the load balancer is what gives the private app server a public
front door. Do not assume the "before" picture is a public single server.

**Rule for next time: on an inspect-the-environment question, go and look. Never
reason from what a good architecture ought to have.**

## The same six questions — how to derive each answer
Do not memorise these; derive them, because the practical test will ask the same
*shape* of question about a different environment.

1. **Which ports are open on CafeSG?**
   EC2 → Security Groups → CafeSG → **Inbound rules** tab. Read them off; expect
   **HTTP 80** and **HTTPS 443** from `0.0.0.0/0`. Note what is *absent*: no SSH,
   because access is via Session Manager.
2. **Can traffic from the internet reach Public Subnet 1?**
   **Yes.** Test = its route table contains `0.0.0.0/0 → igw-…`. That route, and
   only that route, is what makes a subnet public.
3. **Can Private Subnet 1 / Private Subnet 2 reach the internet?**
   Answer each from its **route table**, not from what good design would want.
   Private Subnet 1 already points at the existing NAT gateway → **Yes**.
   Private Subnet 2 has **no NAT route** → **No**, and that gap is what Task 2
   fixes. (Outbound internet for a private subnet is always a **NAT gateway**,
   outbound-initiated only, never an IGW.)
4. **Is CafeWebAppServer reachable from the internet?**
   Three things decide it, all of which must be true: (a) a public IPv4 address,
   (b) its subnet's route table has `0.0.0.0/0 → IGW`, (c) a security group rule
   allowing the port. Check all three and answer from evidence.
   **In this lab the answer is NO** — it is in a private subnet. That is the
   reason the ALB exists.
5. **What is the name of the AMI?**
   EC2 → **AMIs** (owned by me) → **Cafe WebServer Image**. This is the AMI the
   launch template must use, from the **My AMIs** tab (not Quick Start).
6. **What is still not highly available / what is the single point of failure?**
   Before your changes: **one NAT gateway in one AZ**. If that AZ fails, Private
   Subnet 2's instances lose all outbound internet. Fix = **one NAT gateway per
   AZ, with a separate route table per private subnet** pointing at the NAT in
   its own AZ. This is the same answer as the guided lab's optional task and it
   recurs constantly in exams.

## Traps specific to this lab
- **NAT gateway must go in a PUBLIC subnet** — a NAT gateway in a private subnet
  is a dead end. It is placed in the public subnet of AZ 2 but it serves the
  **private** subnet of AZ 2.
- **NAT gateway is AZ-scoped.** Private Subnet 2 must use the NAT gateway in
  *its own* AZ, otherwise you pay cross-AZ charges and reintroduce the SPOF.
- **Connectivity type = Public** on the NAT gateway, and **Allocate Elastic IP** —
  a private NAT gateway has no internet path.
- **Do not edit the existing private route table.** Private Subnet 1 and Private
  Subnet 2 need *separate* route tables; if they share one, adding your route
  breaks AZ 1. Check the **Subnet associations** tab before editing anything.
- **IAM instance profile `CafeRole` lives under Advanced details** in the launch
  template, near the bottom. Miss it and Session Manager will not connect, which
  costs you the whole stress-test task.
- **The resource tag must be applied to Instances** (tick the Instances checkbox),
  not just created.
- **"No load balancer" is deliberate** at ASG creation time. Choosing "Attach to
  an existing load balancer" here is impossible (none exists yet) — resist the
  urge to build the ALB first, because the lab is testing whether you know how to
  attach one afterwards.
- **ALB needs both public subnets**, one per AZ. One subnet = not HA and the
  console will refuse.
- **Max 6, not 2.** The guided lab's 2/2/2 is a different lab.
- **Warmup 60 s** is on the scaling policy, not the ASG health check grace period
  — they are different fields. Instance warmup tells the policy to ignore a new
  instance's CPU while it boots, so the policy does not over-scale.

## Verification pass before you submit (2 minutes, always worth it)
1. NAT gateway: State **Available**, in the **public** subnet of AZ 2, has an EIP.
2. Private Subnet 2's route table: `0.0.0.0/0 → nat-…` **and** Private Subnet 2
   in Subnet associations.
3. Launch template: AMI = Cafe WebServer Image, t2.micro, CafeSG, IAM profile
   CafeRole, tag Name=webserver on Instances.
4. ASG: both private subnets, 2/2/6, target tracking CPU 25 / warmup 60.
5. ALB: internet-facing, both public subnets, its SG allows HTTP from anywhere.
6. Target group: **2 healthy targets**.
7. `http://<ALB-DNS>/cafe` renders the café page in a browser.
8. ASG Activity tab shows at least one scale-out entry from the stress test.

---

## "How do I actually get two AZs?" (asked 2026-09-08)

You do **not** create AZs — they exist in every Region. You create **subnets**,
and **a subnet lives in exactly one AZ**, chosen from a dropdown at creation
time. That is the entire mechanism.

**Region → AZs → a subnet in one AZ → resources in that subnet.**

### The standard four-subnet HA layout
**VPC → Subnets → Create subnet** (use **Add new subnet** to do all four in one
pass). The **Availability Zone dropdown is the whole decision**; CIDRs must not
overlap.

| Subnet | AZ | CIDR |
|---|---|---|
| Public Subnet 1 | us-east-1**a** | 10.0.0.0/24 |
| Public Subnet 2 | us-east-1**b** | 10.0.1.0/24 |
| Private Subnet 1 | us-east-1**a** | 10.0.2.0/24 |
| Private Subnet 2 | us-east-1**b** | 10.0.3.0/24 |

### Each service spans AZs by being GIVEN those subnets
| Service | How |
|---|---|
| **ALB** | Network mapping → tick **2+ AZs**, one subnet each. **Mandatory** — one AZ is refused. |
| **Auto Scaling group** | Select both private subnets; it balances instances across them. |
| **RDS Multi-AZ** | **DB subnet group** with subnets in **≥2 AZs**, then tick Multi-AZ. |
| **EFS** | A **mount target in each AZ**. |
| **NAT gateway** | **One per AZ** — AZ-scoped, does **not** fail over. (Module 10 challenge Task 2.) |

### NOT multi-AZ — traps
- **EBS volume**: one AZ, attaches only to an instance in that same AZ.
- **A single EC2 instance**: one AZ. Redundancy comes from the ASG, not the instance.
- **NAT gateway**: one AZ.

### AZ letter vs AZ ID
`us-east-1a (use1-az2)`: the **letter is per-account** — one account's `us-east-1a`
may be a different physical zone from another's. The **AZ ID** (`use1-az2`) is the
same physical zone for everyone. Never needs acting on; just know what it is.

**RULE: if a requirement says "highly available" or "fault tolerant", the first
thing you build is subnets in two different AZs — everything else references them.**

---

## ASG timers — which one to change (asked 2026-09-08)

Two distinct kinds of timer. Pick by what "fail" means in the question.

### A. Before a failing instance is declared unhealthy and replaced
- **Health check grace period** — ASG → Details → **Health checks → Edit**. Default
  **300 s**. How long after launch the ASG **ignores** health checks. Fixes the
  classic loop: app takes 4 min to boot, ALB marks it unhealthy at 60 s, ASG
  terminates and relaunches forever. **Raise it above the app's boot time.**
- **Health check type** — same screen: **EC2** (is the instance running?) vs
  **ELB** (is the app responding?). With a load balancer, **ELB** is the answer,
  and it is commonly graded.
- **Target group health checks** — Target Groups → Health checks → Edit → Advanced:

| Setting | Default | Effect |
|---|---|---|
| Interval | 30 s | How often it checks |
| Unhealthy threshold | 2 | Consecutive failures before "unhealthy" |
| Timeout | 5 s | How long to wait for a response |
| Healthy threshold | 5 | Consecutive passes to recover |

**Detection time = Interval × Unhealthy threshold** (default 30 × 2 = **60 s**).
Raise either to tolerate a blip.

### B. Between scaling activities
- **Default instance warmup** — on the **scaling policy**. New instance's metrics
  are ignored while it boots, so the policy does not over-scale.
- **Default cooldown** — ASG → Details → Advanced configurations, default 300 s.
  Pause after a scaling activity before another may start; stops thrashing.

### Wording → answer
| Question wording | Answer |
|---|---|
| "instances replaced before the application finishes starting" | **Increase the health check grace period** |
| "ASG should use the load balancer's view of health" | **Health check type = ELB** |
| "a brief blip should not cause a replacement" | **Raise unhealthy threshold / interval** on the target group |
| "group adds too many instances at once" | **Increase instance warmup / cooldown** |
