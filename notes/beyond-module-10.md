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
