# Authoritative lab → module map (from Canvas, 2026-09-07)

Modules 1, 2, 12, 15, 17 have **no lab**. Capstone and the (Optional)
Microservices lab are **skippable** (lecturer's instruction).

| Mod | Lab | Pts | Status |
|-----|-----|-----|--------|
| 3 | Guided: Exploring AWS IAM | 56 | ✅ Jul 10 |
| 4 | Challenge (Cafe): Creating a Static Website for the Cafe | 29 | ✅ Jul 10 |
| 5 | Guided: Introducing Amazon EFS | 15 | ✅ Jul 15 |
| 5 | Challenge (Cafe): Creating a Dynamic Website for the Café | 30 | ✅ Jul 29 |
| 6 | Guided: Creating an Amazon RDS Database | 20 | ✅ Jul 17 |
| 6 | Challenge (Cafe): Migrating a Database to Amazon RDS | 25 | ✅ Sep 2 |
| 7 | Guided: Creating a Virtual Private Cloud | 56 | ✅ Jul 17 |
| **7** | **Challenge (Cafe): Creating a VPC Networking Environment for the Café** | **56** | ❌ **TODO** |
| 8 | Guided: Creating a VPC Peering Connection | 56 | ✅ Sep 6 |
| 9 | Guided: Securing Applications by using Amazon Cognito | 56 | ✅ Sep 6 |
| 9 | Guided: Encrypting Data at Rest by Using AWS Encryption Options | 56 | ✅ Sep 7 |
| 10 | Guided: Creating a Highly Available Environment | 56 | ✅ Sep 7 |
| **10** | **Challenge (Café): Creating a Scalable and HA Environment for the Café** | **56** | ❌ **TODO** |
| **11** | **Guided: Automating Infrastructure with AWS CloudFormation** | **56** | ❌ **TODO** |
| **11** | **Challenge (Café): Automating Infrastructure Deployment** | **56** | ❌ **TODO** |
| **13** | **Guided: Building Decoupled Applications by Using Amazon SQS** | **56** | ❌ **TODO** |
| 14 | Guided: Implementing a Serverless Architecture on AWS | 56 | ✅ Sep 7 |
| 14 | (Optional) Breaking a Monolith into Microservices | 56 | ⏭️ SKIP |
| **14** | **Challenge (Café): Implementing a Serverless Architecture for the Café** | **56** | ❌ **TODO** |
| 16 | Guided: Storage Gateway S3 File Gateway | 40 | ⚠️ 5/40, SCP-blocked |
| – | Capstone Project | 35+56 | ⏭️ SKIP |

**6 outstanding = 336 points.** Only **two** are in test scope (Modules 7 and 10),
and both are Challenge labs — so they pay coursework marks *and* rehearse the test.

## Two things this list revealed about TEST SCOPE

1. **Amazon EFS is in Module 5** (Adding a Compute Layer) — so it IS examinable.
   See the EFS section added to `modules/05-ec2-compute.md`.
2. **Module 9 contains "Managing access to multiple accounts"** — i.e. AWS
   Organizations and **Service Control Policies**. The SCP that blocked the
   Storage Gateway lab on 2026-09-07 is therefore **directly examinable material**,
   not just a lab annoyance.
3. Module 10 contains four **Route 53** topics (simple / failover / geolocation
   routing) — routing policies are in scope.
4. Module 7 contains **VPC endpoints** ("Connecting to managed AWS services") and
   **VPC Flow Logs** ("Monitoring your network").
