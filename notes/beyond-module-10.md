# Modules 11–17 — NOT in the practical test

Confirmed from Canvas on 2026-09-04. The practical test covers **Modules 1–10**
only. Help on these later modules is fine for coursework, but it is tracked here
so it never gets confused with test preparation.

| # | Module (exact Canvas title) | Core services |
|---|------------------------------|---------------|
| 11 | Automating Your Architecture | **CloudFormation** (see `modules/11-automating-architecture-NOT-IN-TEST.md`) |
| 12 | Caching Content | CloudFront, ElastiCache, edge caching |
| 13 | Building Decoupled Architectures | SQS, SNS, EventBridge |
| 14 | Building Serverless Architectures and Microservices | Lambda, API Gateway, DynamoDB |
| 15 | Data Engineering Patterns | Kinesis, Glue, Athena, Redshift |
| 16 | Planning for Disaster | **RTO/RPO, backup & restore, pilot light, warm standby, multi-site** |
| 17 | Bridging to Certification | SAA-C03 exam preparation |
| – | Capstone Project | End-to-end build |

## Two boundary warnings
- **CloudFormation** feels like core architecting and appears in many AWS
  practicals — but here it is **Module 11**, outside the test.
- **Disaster recovery vocabulary (RTO, RPO, pilot light, warm standby)** is
  **Module 16**, outside the test. High availability *within* a Region
  (Multi-AZ, ALB, Auto Scaling) is Module 10 and **is** tested. Don't confuse
  the two: HA is in, DR is out.

## Log of help given on out-of-scope modules
| Date | Module | Topic | Notes |
|------|--------|-------|-------|
| 2026-09-04 | 14 | Guided Lab: Implementing a Serverless Architecture (S3 → Lambda → DynamoDB → Streams → Lambda → SNS) | The six `inventory-*.csv` download links did not work. Regenerated the files from the schema `store,item,count` (Berlin reproduced exactly from the lab text; the other five built to match, each with one zero-count item so the SNS alert fires). Files are in the session scratchpad, not committed. |
| 2026-09-04 | 14 | Debugged the serverless pipeline: DynamoDB empty despite 6 successful Lambda invocations | Duration of ~2 ms gave it away — the Lambda code had been saved but not **Deployed**, so the default placeholder handler ran. S3 event notification was fine (6 invocations = 6 files). |
| 2026-09-04 | 16 | Guided Lab: Configuring Hybrid Storage and Migrating Data with AWS Storage Gateway S3 File Gateway (~90 min) | S3 File Gateway (NFS) + S3 cross-Region replication across 3 Regions. Notes below. |


---

## Module 16 lab: Storage Gateway S3 File Gateway + cross-Region replication

### Three Regions in play
| Region | What lives there |
|---|---|
| us-east-1 N. Virginia | the "on-premises" Linux server + the File Gateway appliance |
| us-east-2 Ohio | **source** bucket (primary) |
| us-west-2 Oregon | **destination** bucket (CRR target) |

### S3 File Gateway in one line
It presents a normal **NFS (or SMB) file share** on your local network; every
file written to that share becomes an **S3 object, one-to-one**, with a local
**cache disk** keeping recently used data fast. Existing applications keep using
a filesystem while the data actually lands in S3.

### The three Storage Gateway types
| Type | Presents | Backed by | Use for |
|---|---|---|---|
| **S3 File Gateway** | NFS / SMB file share | S3 objects | file data, migration, hybrid file storage |
| **Volume Gateway** | iSCSI block volumes | EBS snapshots | block storage; *cached* (primary in AWS) or *stored* (primary on-prem) |
| **Tape Gateway** | virtual tape library (VTL) | S3 / Glacier | replacing physical tape backup |

### Cross-Region Replication (CRR) requirements
- **Versioning enabled on BOTH buckets** — hard requirement, the usual exam point.
- An **IAM role** granting S3 permission to replicate (lab: `S3-CRR-Role`).
- Replicates only objects created **after** the rule exists. Existing objects need
  a one-time **S3 Batch Operations** job (that is the prompt the lab mentions).
- **Asynchronous** — can take up to ~15 minutes.
- **SRR** (same-Region replication) is the sibling: log aggregation, compliance,
  keeping data in one Region.

Why replicate: **disaster recovery**, compliance / data residency, and lower
latency for users near the second Region.

### Appliance settings that must be exact
m5.xlarge (only type allowed here) · On-Prem-VPC / On-Prem-Subnet ·
**auto-assign public IP enabled** · **both** security groups (FileGatewayAccess
+ OnPremSshAccess) · root 80 GiB **plus a second 150 GiB volume for cache** ·
key pair `vockey` · wait for **3/3 checks passed** (not 2/2).

Ports the gateway needs: 80 (activation), 443 (HTTPS to AWS), 53 (DNS),
123 (NTP), **2049 (NFS)**.

### Errors in the lab text — do not be confused by these
1. **Task 6 step 57** says the destination bucket is in "US East (N. Virginia)
   us-east-1". It is not — you created it in **us-west-2 (Oregon)** in Task 2.
2. The mount path is written as `/mnt/nfs/s3*` — the trailing `*` is a
   formatting artifact. **Type `/mnt/nfs/s3` with no asterisk.**
3. The objectives and conclusion mention creating an **S3 lifecycle policy**,
   but no task in the instructions actually does it.

### Nice detail
After mounting, `df -h` reports the share as **8.0E (exabytes)** — S3 has no
fixed capacity, so the gateway advertises an effectively unlimited filesystem.

### Lab environment fault found 2026-09-04 (Module 16 Storage Gateway lab)
`s3:CreateBucket` is **denied by a Service Control Policy** in the AWS Academy
account, and the deny is **Region-scoped**: bucket creation works in
**us-east-1** but fails in **us-east-2**, which the lab requires.

```
User: arn:aws:sts::919382086113:assumed-role/voclabs/... is not authorized to
perform: s3:CreateBucket ... with an explicit deny in a service control policy:
arn:aws:organizations::150384205273:policy/o-y4yn0eoyjj/service_control_policy/p-c4b03215
```

Not fixable by a student — restarting the lab does not help, because an SCP is
attached to the AWS Organization, not the session. Reported to the educator.
Workaround for learning: run CRR between whichever Regions the SCP does allow;
the concepts are identical.
