# Practical test format — CONFIRMED by lecturer (2026-09-07)

**Date: 9 September 2026. Scope: Modules 1-10, PLUS DynamoDB.**

- **4 tasks**
- **Each task covers a DIFFERENT service** (examples given: task 1 Auto Scaling,
  task 2 VPC)
- Tasks are **independent**, not one connected build

## What this format means for strategy
1. **A failure does not cascade.** Each task is scored on its own, so a task you
   cannot finish costs only that task. Never let one task eat the clock.
2. **Budget the time evenly** — roughly (total time ÷ 4) per task. If a task
   overruns its slice, leave it and move on; come back only at the end.
3. **Do the task you are most confident on FIRST**, to bank marks early.
4. Expect each task to be a **small self-contained build**, not a full
   three-tier architecture. Think "create a VPC with public and private subnets"
   rather than "build the entire café application".

## Services confirmed / likely
| Likelihood | Service | Module |
|---|---|---|
| **Confirmed** | Auto Scaling (+ ALB) | 10 |
| **Confirmed** | VPC (subnets, IGW, NAT, route tables) | 7 |
| **Confirmed** | **DynamoDB** | 6 |
| Likely 4th | S3 / EC2 / IAM | 4 / 5 / 3 |

## Revision priority given this format
1. **VPC build from scratch** — `notes/build-order.md` steps 1-6
2. **ALB + Auto Scaling build** — launch template, target group, 2 AZs
3. **DynamoDB table creation** — see `modules/06-database-layer.md`
4. **S3 bucket + policy / static hosting**, **EC2 launch + user data + SG**,
   **IAM policy JSON**

---

## Module → service mapping, checked 2026-09-07

| Mod | Content | Buildable task? |
|---|---|---|
| 1 | Welcome only — student guide. **No lab, no knowledge check.** | no |
| 2 | Cloud architecting, **Well-Architected Framework**, global infrastructure | concept only |
| 3 | **IAM** — users, groups, roles, policy JSON, MFA | ✅ yes |
| 4 | **S3** — buckets, static hosting, policies, versioning, storage classes | ✅ yes |
| 5 | **EC2** ← the core: AMI, instance types, **user data**, pricing options, key pairs, SGs. EBS/EFS are the storage sub-topic, NOT the whole module | ✅ yes |
| 6 | **RDS** (Multi-AZ, read replicas, backups, migration) + **DynamoDB** | ✅ yes |
| 7 | **VPC** — subnets, IGW, NAT, route tables, SG/NACL, endpoints, flow logs | ✅ yes |
| 8 | **Transit Gateway**, VPC peering, Site-to-Site VPN, Direct Connect | peering yes |
| 9 | Managing permissions, federation (**Cognito**), **Organizations/SCPs**, **KMS** encryption | KMS yes |
| 10 | **Auto Scaling**, **ELB**, **CloudWatch**, **Route 53** routing policies | ✅ yes |

### Judgements
- **Cognito is unlikely to be a build task** — it needs a working application to
  authenticate against, which does not fit a short discrete task. **KMS is the
  much more likely Module 9 task** (create a customer managed key → encrypted
  EBS volume → attach).
- Module 5 tasks will be **EC2-centric** (launch + user data + security group),
  not EFS.
- A Module 10 task will very likely pair **Auto Scaling with an ALB**.

### Ranked prediction for the unknown 4th task
1. **EC2** — launch with user data + SG (Mod 5)
2. **S3** — bucket + static website hosting + bucket policy (Mod 4)
3. **IAM** — user/group/least-privilege policy (Mod 3)
4. **KMS** — key + encrypted volume (Mod 9)

### Note
DynamoDB will be covered in the **Learner Lab** with the lecturer after the
challenge labs are done, so there will be hands-on practice for it.
