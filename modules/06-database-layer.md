# Module 6 — Adding a Database Layer

**Status:** not started | **Confidence:** –

## Scope
Managed relational and NoSQL databases, and when to choose which.

## Key concepts to know cold
- **RDS engines:** MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, **Aurora**.
- **Multi-AZ deployment = high availability.** Synchronous replication to a
  standby in another AZ. The standby serves **no traffic**; it exists for
  automatic failover (DNS CNAME flips to the standby).
- **Read replica = read scaling.** Asynchronous replication; replicas *do*
  serve read traffic; can be cross-Region; can be promoted to standalone.
- **DB subnet group:** must contain subnets in **at least two AZs** — you
  cannot create an RDS instance without one.
- **Backups:** automated backups (retention 0–35 days, point-in-time recovery)
  vs manual snapshots (kept until you delete them).
- **Encryption at rest** must be decided at creation for RDS; to encrypt an
  existing unencrypted DB, snapshot → copy snapshot with encryption → restore.
- **DynamoDB:** managed NoSQL, key-value/document. Partition key (+ optional
  sort key), on-demand or provisioned capacity, single-digit ms latency,
  automatically replicated across 3 AZs.
- **ElastiCache:** in-memory caching (Redis / Memcached) to take read load off
  the database.
- **Database on EC2 vs RDS:** EC2 gives full control (and full admin burden);
  RDS is managed (patching, backups, failover) but no OS access.

## Typical AWS Academy lab
Migrating the café's database from a database running **on the EC2 instance**
to an **Amazon RDS** instance, then repointing the application's connection
settings at the RDS endpoint.

## High-yield gotchas (marks lost here)
- Multi-AZ ≠ read replica. Multi-AZ is for **availability**, read replicas are
  for **performance**. A scenario about "reduce load on the primary" = read replica.
- The app connects to the RDS **endpoint DNS name**, never to an IP — failover
  changes the underlying host.
- The RDS security group must allow the **database port (3306/5432) from the
  web tier's security group**, not from 0.0.0.0/0.
- Put the database in **private subnets**, never public. "Publicly accessible = No".
- You cannot SSH into an RDS instance — configuration is via parameter groups.

## Self-check questions
1. Multi-AZ or read replica: (a) survive an AZ outage, (b) speed up reporting queries?
2. Why must a DB subnet group span two AZs even for a single-AZ database?
3. Your web app can't reach the DB. Name the two most likely causes.
4. When would you run a database on EC2 instead of RDS?

## My notes
_(fill in as we go)_

---

# Amazon DynamoDB — CONFIRMED extra topic for the practical test

## Creating a table (console click path)
```
DynamoDB → Tables → Create table
  Table name:      <name>
  Partition key:   <attribute name> + type (String / Number / Binary)
  Sort key:        optional  ← only if the brief asks for it
  Table settings:  Default settings  (or Customize settings)
      Capacity mode: On-demand  |  Provisioned (RCU/WCU)
  → Create table
```
Then **Explore table items → Create item** to add data.

## The key concepts

**Primary key — two forms:**
- **Partition key alone** (simple) — must be unique per item.
- **Partition key + sort key** (composite) — the *combination* must be unique.
  Lets you store many items under one partition key and query a range.

A good partition key has **high cardinality** and spreads requests evenly
(e.g. `userID`, not `country`), because DynamoDB hashes it to pick a partition.

**Capacity modes:**
| | On-demand | Provisioned |
|---|---|---|
| You specify | nothing | **RCU / WCU** |
| Pay for | each request | reserved throughput |
| Best for | unpredictable / spiky / new apps | steady, predictable traffic |
| Cheaper when | traffic is bursty or unknown | traffic is steady (and can auto scale) |

**Secondary indexes:**
| | **GSI** (Global) | **LSI** (Local) |
|---|---|---|
| Partition key | **different** from the table | **same** as the table |
| Sort key | any | different |
| When created | **any time** | **only when the table is created** |

*"Query by an attribute that is not the partition key"* → **GSI**.

**Other features worth naming:**
- **DynamoDB Streams** — captures item-level changes; can invoke Lambda
  (this is what drove the Check-Stock function in the Module 14 lab).
- **TTL** — auto-deletes expired items, free.
- **Point-in-time recovery (PITR)** — restore to any second in the last 35 days.
- **Encryption at rest** is on by default.
- **Global tables** — multi-Region, multi-active replication.
- **DAX** — in-memory cache, microsecond reads.
- Reads are **eventually consistent by default**; strongly consistent reads cost
  twice as much.

## Why DynamoDB instead of RDS
NoSQL key-value/document · single-digit millisecond latency at any scale ·
serverless, no instances to manage · automatically replicated across **3 AZs** ·
schema-less (only the key attributes are fixed).
Choose **RDS** when you need joins, complex queries or transactions across
tables; choose **DynamoDB** for high-volume key-based lookups.

## Likely practical task shape
"Create a DynamoDB table named X with partition key Y (and sort key Z), using
on-demand capacity, then add N items." Read the brief for whether a **sort key**
and which **capacity mode** are specified — those are the marked details.

---

**First-time console walkthrough:** see `notes/dynamodb-console-walkthrough.md`
(written 2026-09-08) — every screen, the on-demand vs provisioned decision, the
"you cannot query a non-key attribute" constraint, GSI vs LSI, projections, PITR
vs on-demand backup, TTL and Streams.

---

## "Database migration" in Module 6 — what it actually means (2026-09-09)
It is the **café lab: move MySQL off the EC2 instance into Amazon RDS**. It is
**not AWS DMS** — DMS is not an ACAv3 module topic and is very unlikely in the test.

### The shape of the task
1. **DB subnet group** — subnets in **at least 2 AZs** (mandatory even for a
   single-AZ database).
2. **Create the RDS instance** — **private** subnets, **Publicly accessible = No**,
   security group allowing **3306 from the app server's security group** (never a CIDR).
3. **Export and import** (code is handed over; not graded):
```bash
mysqldump --user=root --password='<pw>' --databases cafe_db > cafedb-backup.sql
mysql --user=admin --password='<pw>' --host=<endpoint>.us-east-1.rds.amazonaws.com < cafedb-backup.sql
mysql --user=admin --password='<pw>' --host=<endpoint>.us-east-1.rds.amazonaws.com \
      --execute="SHOW DATABASES; USE cafe_db; SELECT * FROM product;"
```
4. **Repoint the app at the RDS ENDPOINT DNS NAME** — never an IP address;
   failover changes the underlying host.

**All the marks are console-side:** subnet group across 2 AZs · private subnets ·
Publicly accessible = No · SG source = the app tier's SG · app uses the endpoint name.

---

## Moving things between AZs and Regions — the three mechanisms (do not conflate)
| Goal | Mechanism |
|---|---|
| EBS volume → **another AZ**, same Region | **Snapshot → create volume from snapshot, choosing the AZ.** No copy step: snapshots are already **Region-wide**. |
| EBS volume → **another Region** | **Snapshot → Copy snapshot** to that Region → create volume there |
| A whole server → **another Region** | **Create AMI → Copy AMI** → launch from it there (copying the AMI copies its snapshots automatically) |
| S3 objects → another bucket/Region | **S3 Replication (CRR/SRR)** — unrelated to EBS/AMI |

- Copying an **encrypted** snapshot cross-Region needs a **KMS key in the
  destination Region** — KMS keys do not cross Regions.
- A copied AMI gets a **new AMI ID** in the destination Region. Anything
  referencing the old ID (launch template, CloudFormation mapping) must be updated
  — that is why templates carry a `RegionMap`.

**S3 Replication requirements (commonly graded):** versioning on **BOTH** buckets ·
an **IAM role** · **only objects created AFTER the rule** replicate (existing ones
need **Batch Replication**) · replication is **asynchronous**.

**Scope note:** AMIs/snapshots are **Module 5 (in scope)**. Cross-Region copy as a
*DR strategy* (RTO/RPO, pilot light, warm standby) is **Module 16 — OUT of scope**.
Know the mechanism in one sentence; do not drill it.
