# Progress Tracker

**Course:** AWS Academy Cloud Architecting (ACAv3) — course 174939
**Assessment 1:** Practical test covering **Modules 1–10**
**Assessment 2 — DEADLINE 8 SEPTEMBER 2026, MIDNIGHT:** coursework marks require
**all guided labs across all modules** to be completed and submitted. This
includes modules outside the practical-test scope (11-17), so "out of scope for
the test" does NOT mean "skippable".
**Branch:** `claude/cloud-computing-practice-8s3q0y` (main is source of truth)

---

## URGENT — see `notes/deadline-plan.md`
6 labs outstanding, ~336 points, due 8 Sept midnight; practical test 9 Sept.
Four of the six are **Challenge labs**, which are scenario-based and therefore
double as practical-test practice.

## Next step
> **In progress: Module 10 Challenge (Café) lab — Creating a Scalable and Highly
> Available Environment.** Run sheet is in `modules/10-monitoring-elasticity-ha.md`
> (build order, the six inspection questions, and the traps). The single most
> missed step is **attaching the target group to the ASG after the ALB is built** —
> the ASG is deliberately created with *no* load balancer.
>
> **PHASE 2 HAS STARTED** — the user asked for a practice question on
> 2026-09-08. First task issued: `notes/practice/dynamodb-q1.md` (DynamoDB,
> scenario format, awaiting their answer to mark).
>
> **Revision plan for the test: `notes/revision-checklist.md`** — tiered build
> drills in the Learner Lab (Tier 1 ~2 hrs: VPC, EC2+SG, ALB+ASG, DynamoDB, S3,
> IAM), with per-drill teardown to protect the $50 budget.
> Still to get: confidence ratings (1-5) for Modules 7, 8, 9 and 10.

---

## Status by module

Legend: `not started` · `reading` · `lab done` · `covered` · `confident`

| # | Module (Canvas title) | Status | Confidence (1-5) | Notes |
|---|-----------------------|--------|------------------|-------|
| 1 | Welcome to AWS Academy Cloud Architecting | not started | – | |
| 2 | Introducing Cloud Architecting | not started | – | |
| 3 | Securing Access | not started | – | IAM foundations |
| 4 | Adding a Storage Layer with Amazon S3 | not started | – | |
| 5 | Adding a Compute Layer Using Amazon EC2 | **covered** | – | EC2 + SGs + launch templates + **EFS built and verified** 2026-09-08 |
| 6 | Adding a Database Layer | **covered** | – | **DynamoDB built** 2026-09-08 (table, GSI, PITR, items). RDS read-only revision. |
| 7 | Creating a Networking Environment | **lab done** | – | Guided + **Challenge lab** walked through 2026-09-08 (VPC, subnets, IGW, NAT, route tables, NACLs) |
| 8 | Connecting Networks | **lab done** | – | VPC peering guided lab walked through 2026-09-04 |
| 9 | Securing User, Application, and Data Access | **lab done** | – | Cognito guided lab **30/30** (2026-09-04) |
| 10 | Implementing Monitoring, Elasticity, and High Availability | **covered** | – | Challenge lab + **full ALB/ASG build from scratch 2026-09-08**, incl. debugging 502 and a blank launch template version |

**Out of scope (Modules 11-17 + Capstone):** see `notes/beyond-module-10.md`.
Notably **CloudFormation (Mod 11)** and **DR / RTO / RPO (Mod 16)** are NOT tested.

**Known from Canvas:** Knowledge Checks for three modules scored 100/100
(seen on the course home page; these are multiple-choice recall, not build skill).

---

## Weak areas to revisit
- **Public vs private subnet routing** (IGW vs NAT, and that the NAT gateway
  *lives in* a public subnet). Explained 2026-09-04; revisit.
- **Working without step-by-step instructions** — the user's own stated concern:
  guided labs give the steps, the practical gives only a scenario. See
  `notes/build-order.md` (build order + requirement-to-action translation).

---

## Session log

### 2026-09-04 — Session 1
- Established scope: practical test covers Modules 1–10 (confirmed by lecturer).
- Set up this repo as the study record.
- Built an optional offline AWS CLI sandbox (moto) for rehearsing commands
  without consuming AWS Academy lab time.
- Wrote coverage notes for all ten modules in `modules/`.
- Agreed the working method: **Phase 1** = cover Modules 1-10 with guidance and
  explanation, **no practice questions**. **Phase 2** = practice questions,
  started only when the user asks.
- Agreed help on later modules (11, 12, ...) is in scope for coursework, but
  tracked separately in `notes/beyond-module-10.md`.
- Moved the record to `main` at the user's request.
- **Confirmed the real course structure from Canvas: 17 modules, not the
  standard layout previously assumed.** Renumbered every file in `modules/`.
  Key corrections: Module 3 is *Securing Access* (IAM foundations, previously
  missing entirely); S3/EC2/DB/VPC all shifted one number later; **CloudFormation
  is Module 11 and NOT in the test**; **DR/RTO/RPO is Module 16 and NOT in the test**.
- Walked through the **Module 8 guided lab: Creating a VPC Peering Connection**
  (peering handshake, routes on both sides, VPC Flow Logs, troubleshooting order).
- Guided the **Module 9 guided lab: Securing Applications by Using Amazon
  Cognito** live, start to finish. **Result: 30/30.** Debugged three real
  errors along the way: doubled Cognito domain (prefix vs full domain), an
  unreplaced `<cognito-user-pool-id>` placeholder in `package.json`, and an
  S3 `AccessDenied` from navigating directly to `/report`.

### 2026-09-08 — Session (deadline day)
- Worked the **Module 7 Challenge lab: Creating a VPC Networking Environment**:
  route table subnet associations, the custom **Lab Network ACL** on Private
  Subnet, and the outbound Deny rule (rule 50, All ICMP-IPv4) — including the
  NACL rules being **stateless, ascending-number, first-match-wins**.
- Wrote the **Module 10 Challenge (Café) lab run sheet** into
  `modules/10-monitoring-elasticity-ha.md`: build order with checkpoints, the
  five differences from the guided HA lab, symptom→cause map (503 vs 504 vs 404),
  the stress-test maths (1 vCPU pinned to 100% ⇒ group average ~50% > target 25),
  how to derive each of the six inspection answers, and a pre-submit checklist.
- Recorded the highest-value trap of that lab: the ASG is built **with no load
  balancer**, so the target group must be **attached to the ASG afterwards** via
  ASG → Integrations/Load balancing → Edit. Skipping it gives a 503 and loses
  every scaling mark.
- Platform note: the Vocareum lab pages had been spinning earlier (confirmed not
  browser-related via incognito); see `notes/deadline-plan.md`.

### 2026-09-08 (late) — Learner Lab build drills, night before the test
Moved to the **AWS Academy Learner Lab** ($50 budget) for hands-on drills. Agreed
two standing rules, both now in `CLAUDE.md`: **no coding in the test** (so hand
over code complete), and **every task ends with a teardown list**.

Built by hand, unguided:
- **DynamoDB** — first time ever. `DemoProducts` walkthrough (items, scan vs query,
  the "cannot query a non-key attribute" constraint, GSI, sparse index behaviour,
  projections), then the `CafeOrders` practice task. Phase 2 started.
- **VPC from scratch** — VPC, 4 subnets across 2 AZs, IGW, NAT gateway, both route
  tables with associations, auto-assign public IP.
- **Security groups** — `alb-sg` / `app-sg` / `efs-sg` chain derived from the arrows.
- **ALB + Auto Scaling** — launch template, ASG (no LB), ALB, target group,
  **attached the target group to the ASG afterwards**, healthy targets, load test
  with `stress`.
- **EFS** — `efs-sg` (NFS 2049 from `app-sg`), mount targets in both private
  subnets, mounted on two instances in two AZs, wrote on one and read on the other.

Debugged for real, all logged: **502 vs 503 vs 504**; a **launch template version
saved blank** because "Source template version" was not set; a tag placed under
**Template tags** instead of **Resource tags**; a **wrong EFS file system ID**;
**python3-botocore** missing for the EFS mount helper; and a **silently failed
mount** that made a local folder look like EFS.

Concepts nailed down along the way: Elastic IPs (three-question test, and that an
EIP never makes anything public), how multi-AZ is actually achieved (subnets, not
AZs), which ASG timer to change for which symptom, launch template versioning
semantics, and that a security group belongs to a **resource**, not to a link.
