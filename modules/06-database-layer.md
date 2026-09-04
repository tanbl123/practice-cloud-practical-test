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
