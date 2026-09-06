# Building From Scratch — the practical-test playbook

The guided labs tell you what to click. A practical test gives you a **scenario**
and expects you to derive it. This file is the bridge: a fixed build order that
works for any scenario, and a table for translating requirement wording into
AWS actions.

---

## Part 1: The build order (dependency chain)

You cannot reorder these. Each step needs the one before it to exist.

```
1. VPC                 pick the CIDR first (10.0.0.0/16)
        |
2. SUBNETS             2 public + 2 private, across 2 AZs
        |
3. INTERNET GATEWAY    create it AND attach it to the VPC (two actions!)
        |
4. PUBLIC ROUTE TABLE  add 0.0.0.0/0 -> igw
   + ASSOCIATE         attach it to both public subnets  <-- most missed step
        |
5. NAT GATEWAY         create IN A PUBLIC SUBNET, allocate an Elastic IP
                       (one per AZ if the brief says highly available)
        |
6. PRIVATE ROUTE TABLE add 0.0.0.0/0 -> nat
   + ASSOCIATE         attach it to the private subnets
        |
7. SECURITY GROUPS     build top-down: ALB <- internet, app <- ALB, db <- app
        |
8. RESOURCES           RDS (needs a DB subnet group spanning 2 AZs)
                       AMI -> launch template -> target group -> ALB -> ASG
```

### Why the order is forced
- A route table cannot be associated with a subnet that does not exist yet.
- A NAT gateway needs a **public** subnet that already routes to the IGW.
- An ALB needs **two subnets in two AZs** selected at creation.
- An RDS instance cannot be created without a **DB subnet group** (2+ AZs).
- An Auto Scaling group needs a **launch template** and (usually) a **target
  group** to already exist.

### CIDR quick math
| Block | Total IPs | Usable (5 reserved) |
|---|---|---|
| /16 | 65,536 | 65,531 |
| /24 | 256 | **251** |
| /26 | 64 | **59** |
| /28 | 16 | 11 (smallest allowed) |

Standard four-subnet layout inside 10.0.0.0/16:
```
10.0.0.0/24  Public Subnet 1   (AZ a)
10.0.1.0/24  Public Subnet 2   (AZ b)
10.0.2.0/24  Private Subnet 1  (AZ a)
10.0.3.0/24  Private Subnet 2  (AZ b)
```

---

## Part 2: Requirement wording -> what to build

| The brief says... | You build |
|---|---|
| "highly available", "survive an AZ / data centre failure" | **Two AZs**: subnets in 2 AZs, ALB across both, ASG min 2, RDS Multi-AZ |
| "must not be reachable from the internet" | **Private subnet** (no IGW route) |
| "needs to download updates / patches / call an API" | **NAT gateway** in a public subnet + private route `0.0.0.0/0 -> nat` |
| "handle varying / unpredictable load", "scale automatically" | **Auto Scaling group + target tracking policy** |
| "predictable busy period every Monday 9am" | **Scheduled scaling** |
| "distribute traffic across servers" | **ALB** + target group + health checks |
| "route by URL path or hostname" | **ALB** (layer 7) |
| "extreme performance, static IP, TCP" | **NLB** (layer 4) |
| "web servers talk to the database only" | DB SG inbound **from the app SG** (a group, never a CIDR) |
| "least privilege" | Named **actions** + named **resource ARNs**; no `*` |
| "application needs access to an AWS service" | **IAM role** (instance profile), never access keys |
| "temporary credentials" | **IAM role / STS** |
| "users sign in to the app" | **Cognito user pool** |
| "the signed-in app must call DynamoDB/S3" | **Cognito identity pool** |
| "database password must rotate automatically" | **Secrets Manager** (not Parameter Store) |
| "encrypt data at rest" | **KMS key** / SSE-S3 / EBS + RDS encryption **at creation** |
| "audit who used the encryption key" | **CloudTrail** |
| "notify someone when X happens" | **CloudWatch alarm -> SNS topic** |
| "reduce read load on the database" | **Read replica** (NOT Multi-AZ) |
| "static website" | **S3 static website hosting** + bucket policy + Block Public Access off |
| "objects rarely accessed, cheaper storage" | **S3 storage class / lifecycle policy** |
| "two VPCs must talk privately" | **VPC peering**, routes on **both** sides, non-overlapping CIDRs |
| "many VPCs, avoid a mesh" | **Transit Gateway** |
| "connect to on-premises quickly and cheaply" | **Site-to-Site VPN** |
| "consistent low latency to on-premises" | **Direct Connect** |
| "see what traffic is being accepted/rejected" | **VPC Flow Logs** |

### Words that are always a trap
- **"Highly available"** with only one AZ selected = no marks. Two AZs, always.
- **"Multi-AZ"** is availability. **"Read replica"** is performance. Never swap them.
- **"Least privilege"** with `"Action": "*"` = no marks.
- Security group **sources** between tiers must be **security groups**, not CIDRs.

---

## Part 3: Verify before you submit

Marks are lost on things that "look done". Check each of these explicitly:

1. **Route table ASSOCIATIONS tab** — not just that the route exists. The single
   most common lost mark.
2. **Two AZs** everywhere the brief says highly available (ALB subnets, ASG
   subnets, DB subnet group).
3. **Security group sources** — are the tier-to-tier ones referencing groups?
4. **Target group health** — targets must read **healthy**, not just registered.
5. **Names exactly as specified** in the brief. Markers often match on names.
6. **Actually load the URL / test the thing.** Do not assume.
7. Old rules that should have been **deleted**, not just added alongside.

---

## Part 4: Time strategy in a timed practical

1. **Read the whole brief first.** Do not start clicking. Two minutes of reading
   saves twenty of rework.
2. **Turn the brief into a checklist** of concrete resources with names.
3. **Build in dependency order** (Part 1). Never jump ahead.
4. **Verify with Part 3** before submitting.
5. If something does not work, troubleshoot **outside-in**:
   routing -> security group -> NACL -> application.
   Symptom tells the layer: **timeout = routing**, **refused = security/app**.

---

## Part 5: Deriving security groups from any scenario

### The only question a security group answers
> **"Who is allowed to talk TO this thing?"**

Not what it needs to reach. Security groups are **stateful** (return traffic is
automatic) and **outbound is allow-all by default** — so you almost never touch
outbound rules.

### The method: draw the arrows, write a rule on each arrowhead
```
Internet  --->  ALB  --->  App servers  --->  Database
```
**Every arrowhead = one inbound rule, on the RECEIVER, naming the SENDER.**

| Rule goes on | Allow FROM | Port |
|---|---|---|
| ALB SG | the internet `0.0.0.0/0` | 80, 443 |
| App SG | **the ALB's security group** | 80 |
| DB SG | **the App's security group** | 3306 |

The rule always lives on the **receiver**. Adding "let the ALB talk out" is the
classic beginner error — outbound is already open.

### Group or CIDR? One decision rule
> **Is the sender something I control inside this VPC?**
> **Yes -> reference its security group. No -> use a CIDR.**

Why it matters: under Auto Scaling, instance IPs are never stable. A security
group reference follows membership automatically; a hardcoded CIDR breaks at the
next scale event. **This is the justification to write in an answer.**

### Ports to know cold
80/443 HTTP/HTTPS · 22 SSH · 3389 RDP · **3306 MySQL/Aurora** ·
**5432 PostgreSQL** · 1433 MS SQL · 1521 Oracle

### Build trick
You cannot reference a security group that does not exist yet. **Create all the
security groups empty first** (names only), then go back and add the rules.
Never get stuck mid-build.

### Two checks
1. **Trace one packet** end to end — does every hop have an inbound rule allowing it?
2. **Does any tier accept traffic from anything other than the tier above it?**
   If yes, either justify it or it is a security hole. (The Module 10 lab's
   original DB rule allowing all of `10.0.0.0/16` is exactly this.)

### It generalises
Any number of tiers, same method. "Admins must SSH from the office" = one more
arrow landing on the app tier = inbound port 22 from the **office CIDR**
(outside the VPC, so a CIDR, not a group).
