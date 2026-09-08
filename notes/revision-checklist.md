# Practical-test revision checklist (written 2026-09-08, test 2026-09-09)

Triaged by **likelihood x weakness x build time**, not module order. Tier 1 is
~2 hours. Everything is a **Learner Lab build drill** — the test is console work,
so reading alone will not fix the "I freeze without step-by-step instructions"
problem.

## Tier 1 — do these first (~2 hrs)

- [ ] **1. VPC from scratch — 25 min — HIGHEST VALUE**
  VPC 10.0.0.0/16 → 2 public + 2 private subnets across 2 AZs → IGW + attach →
  public route table `0.0.0.0/0 → IGW` + **associate both public subnets** →
  NAT gateway in a public subnet + EIP → private route table `0.0.0.0/0 → NAT`
  + **associate the private subnets**.
  *Self-check:* every route table's **Subnet associations** tab is non-empty.
  *Teardown:* delete NAT → wait for Deleted → release EIP → delete VPC. Do it
  immediately; the NAT is the only meaningful cost in this list.

- [ ] **2. EC2 + security groups — 15 min**
  One t2.micro in a public subnet (SG: HTTP from anywhere), one in a private
  subnet whose SG allows traffic **from the first SG, not a CIDR**.
  *Self-check:* the port always belongs to the **receiver**.
  *Teardown:* terminate both.

- [ ] **3. ALB + Auto Scaling — 30 min — MARKS LOST HERE 2026-09-08**
  Launch template → ASG across 2 private subnets → ALB across 2 public subnets →
  **attach the target group to the ASG** → 2 healthy targets.
  *Self-check:* min/desired/max set deliberately; warmup changed from the 300
  default; healthy targets, not a 503.
  *Teardown:* ASG (set to 0, delete) → ALB → target group.

- [ ] **4. DynamoDB — 15 min — NEVER TOUCHED, GUARANTEED TOPIC**
  `notes/dynamodb-console-walkthrough.md`, then `notes/practice/dynamodb-q1.md`.
  *Teardown:* delete the table.

- [ ] **5. S3 — 15 min**
  Bucket → versioning → upload → overwrite → view versions → Block Public Access
  off → bucket policy for public read → static website hosting → open the
  website endpoint.
  *Self-check:* policy Resource ends in **`/*`**; website endpoint != REST endpoint.
  *Teardown:* empty (including versions), then delete.

- [ ] **6. IAM — 10 min**
  Group with a managed policy → user in it → EC2 role with an S3 policy →
  attach the role to a running instance.
  *Self-check:* anything AWS-to-AWS is a **role**, never a user's keys.
  *Teardown:* delete user, group, role.

## Tier 2 — only if Tier 1 is finished

- [ ] **7. EFS — 15 min.** File system, mount targets in both AZs, mount-target
  SG allows **NFS 2049 from the EC2 instances' SG**. That rule is the exam point.
- [ ] **8. CloudWatch alarm → SNS — 10 min.** CPU alarm, SNS topic, email
  subscription — **confirm the subscription email**, the step people forget.
- [ ] **9. KMS — 10 min.** Customer managed key, encrypt an S3 object with it.
  *Teardown:* **schedule deletion, 7 days minimum** — immediate delete is impossible.

## Tier 3 — READ ONLY, do not build (too slow or already solid)

- [ ] **10. RDS** — 20 min just to provision. Read `modules/06-database-layer.md`:
  **Multi-AZ** (HA, synchronous, automatic failover) vs **read replica**
  (performance, asynchronous, manual promotion); DB subnet group needs 2 AZs.
- [ ] **11. VPC peering** — lab already done. Re-read: routes on **both** sides,
  **no transitive peering**, CIDRs must not overlap.
- [ ] **12. Cognito** — scored 30/30. Just: **user pool = authentication**,
  **identity pool = AWS credentials**.

## Reading, no console (~20 min, last thing)
- `notes/build-order.md` — requirement-wording → AWS-action translation table
- `notes/exam-tips.md` — the five most common lost marks
- `notes/mistakes-log.md` — incl. 2026-09-08: **on "inspect the environment"
  questions, go and look; never infer from what good architecture would have**

## Budget discipline
Delete the **NAT gateway** the moment each VPC drill ends (~$1.10/day — the only
thing here that can dent the $50). End of night, all of these must read **0**:
EC2 running instances, Volumes, Elastic IPs, Load Balancers, VPC NAT Gateways.
Check in **every Region you touched**.

---
## Learner Lab reality check (2026-09-08)
- **Drill 6 (IAM) CANNOT be done in the Learner Lab** — creating a user group is
  blocked by the lab's IAM policy. Module 3 is theory-only here:
  groups for people · roles for services (never access keys) · explicit Deny
  always wins · implicit deny is the default · **SCP > IAM**.
  Evaluation order: **SCP deny → explicit deny → explicit allow → implicit deny.**
- Everything else in Tier 1 and Tier 2 was completed successfully:
  VPC from scratch, EC2 + security groups, ALB + Auto Scaling (incl. stress test),
  DynamoDB, S3 (versioning, BPA, bucket policy, static website hosting),
  EFS (mounted across two AZs), EBS (+ snapshot → cross-AZ volume), KMS.
