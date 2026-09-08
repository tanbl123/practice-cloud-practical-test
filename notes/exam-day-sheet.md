# EXAM DAY SHEET — read this, build nothing

## THE FOUR HABITS THAT EARN MARKS
1. **Read the wording for exact names, numbers and subnets.** Where the task is
   explicit, it beats every default. Copy spelling character for character.
2. **On "inspect the environment" questions, GO AND LOOK.** Never infer from what
   a good architecture would have. (Cost 3 marks on 2026-09-08.)
3. **Verify each step before moving on**: route table **subnet associations**,
   target group **healthy**, `df -h` after a mount, the tag on the **instance**.
4. **Timeout = routing/security group. Refused/denied = the app or credentials.**

## BUILD ORDER (never reshuffle)
**VPC → subnets (2 AZs) → IGW + attach → public RT + associate → NAT in a PUBLIC
subnet + EIP → private RT + associate → security groups → resources**

Then: database before app server, app server before load balancer, target group
attached to the ASG **after** the ALB exists.

## PLACEMENT DEFAULTS (task wording always wins)
| Tier | Subnet |
|---|---|
| ALB · NAT gateway · bastion | **Public** |
| App servers / ASG | **Private** |
| RDS / database | **Private**, Publicly accessible = **No** |

**HA = subnets in 2 AZs.** You never create AZs; a subnet lives in exactly one.

## SECURITY GROUPS — derive, don't recall
Draw the arrows. For each box: *what is it listening on* (port) and *what is
immediately to its left* (source).
| SG (on the receiver) | Port | Source |
|---|---|---|
| alb-sg (ALB) | 80 | Anywhere-IPv4 |
| app-sg (instances) | 80 | **alb-sg** |
| db-sg (MySQL) | **3306** | **app-sg** |
| efs-sg (mount targets) | **2049** | **app-sg** |
**The port belongs to the RECEIVER. The source names the SENDER.** Inside the
VPC → a security group; outside → a CIDR. Stateful: never write outbound rules.
NACLs are stateless (need ephemeral 1024-65535), ascending number, first match wins.

## ERROR CODES
| Symptom | Cause |
|---|---|
| ALB **503** | Target group empty (not attached to ASG) or all targets unhealthy |
| ALB **502** | Target reached, app not listening (user data failed / httpd down) |
| ALB **504** | Reached but timed out — SG or hung app |
| **2/2 checks passed** + target unhealthy | Machine fine, **app** not |
| S3 **403** on website | Block Public Access still on, or policy missing **`/*`** |
| S3 **AccessDenied** instead of NoSuchKey | No `s3:ListBucket` |
| `Failed to resolve fs-…` | Wrong file system ID, or VPC DNS resolution/hostnames off |
| Mount **hangs** | Security group (NFS 2049) |
| "must provide the partition key attribute X" | Item and table disagree on the key |

## TRIGGER WORDS
| Wording | Answer |
|---|---|
| "highly available" / "survive an AZ failure" (database) | **Multi-AZ** — standby has **no endpoint**, serves nothing |
| "reduce load on the primary" / "reporting queries" | **Read replica** (own endpoint, reads only, **promote** manually) |
| "static IP" / "whitelisted by a partner firewall" | **Elastic IP** |
| "static IP **for the load balancer**" | **NLB** (an ALB cannot) |
| "private instances need patches/updates" | **NAT gateway** (needs an EIP, lives in a PUBLIC subnet, one per AZ) |
| "private subnet must reach **S3/DynamoDB** privately" / "cut NAT data cost" | **Gateway endpoint** (free, a route table entry) |
| "private subnet must reach any other AWS service privately" | **Interface endpoint** (ENI + security group, costs) |
| "app on EC2 needs AWS access" | **IAM role via instance profile** — never access keys |
| "permissions for many people" | **Groups** |
| "SCP denies, IAM allows" | **SCP wins.** Order: SCP deny → explicit deny → allow → implicit deny |
| "unpredictable / bursty traffic" (DynamoDB) | **On-demand** |
| "query by a non-key attribute" | **GSI** (LSI = table's partition key, creation time only) |
| "restore to any second in the last N days" | **PITR** |
| "revoke access to encrypted data immediately" | **Disable the KMS key** (deletion = schedule, 7-30 days) |
| "control and audit who decrypts" | **SSE-KMS, customer managed key** |
| "recover from an accidental overwrite" | **S3 versioning** (only thing that restores in place) |
| "archive after N days" / "delete logs after a year" | **Lifecycle rule** |
| "unknown access pattern" | **Intelligent-Tiering** |
| "who did what, when" | **CloudTrail** (CloudWatch = metrics/logs; Config = configuration history; Flow Logs = traffic) |
| "same servers in another Region" | **Copy the AMI** (new AMI ID there) |
| "move an EBS volume to another AZ" | **Snapshot → create volume in that AZ** |
| "instances replaced before the app starts" | **Increase the health check grace period** |
| "ASG should use the load balancer's view of health" | **Health check type = ELB** |

## THINGS THAT SILENTLY DON'T WORK
- Route table with a perfect route and **no subnet association**
- IGW **created but not attached**
- Public subnet without **auto-assign public IPv4**
- Target group created but **never attached to the ASG**
- Launch template **new version saved blank** — always set **Source template version**
- Tag under **Template tags** instead of **Resource tags → Instances**
- Launch template edits only affect **new** instances — terminate to replace
- A failed `mount` leaves a local folder that looks identical — **`df -h`**
- An **Elastic IP does not make anything public**; the route table does
- S3 replication skips **existing** objects; both buckets need **versioning**

## RDS QUICK FACTS
DB subnet group needs **2 AZs**, even single-AZ · Public access **No** ·
endpoint is **generated**, use the **DNS name** never an IP · **Initial database
name** is create-time only (or just `CREATE DATABASE`) · encryption is
create-time only (snapshot → copy encrypted → restore) · restore always makes a
**NEW instance with a NEW endpoint** · delete the **replica before** the primary.
Identifier uses **hyphens**; the database name uses **underscores**.

## BEFORE YOU SUBMIT EACH TASK (60 seconds)
Names match the wording · route tables have subnet associations · SGs reference
groups not CIDRs · anything "highly available" spans 2 AZs · the thing actually
works when you open it.
