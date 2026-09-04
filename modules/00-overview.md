# Coverage Map — Modules 1 to 10

**Course structure confirmed from Canvas on 2026-09-04** (17 modules + Capstone).
The practical test covers **Modules 1–10**.

## IN SCOPE — the practical test

| # | Module (exact Canvas title) | Core services | Weight |
|---|------------------------------|---------------|--------|
| 1 | Welcome to AWS Academy Cloud Architecting | – | Low |
| 2 | Introducing Cloud Architecting | Well-Architected Framework | Low–Med |
| 3 | **Securing Access** | IAM foundations, root user, MFA | **High** |
| 4 | **Adding a Storage Layer with Amazon S3** | S3 | **High** |
| 5 | **Adding a Compute Layer Using Amazon EC2** | EC2, EBS, AMI, user data | **High** |
| 6 | **Adding a Database Layer** | RDS, DynamoDB | Medium |
| 7 | **Creating a Networking Environment** | VPC, subnets, IGW, NAT, SG/NACL | **High** |
| 8 | **Connecting Networks** | Peering, TGW, VPN, Direct Connect | Medium |
| 9 | **Securing User, Application, and Data Access** | IAM roles, KMS, Secrets Manager, Cognito | **High** |
| 10 | **Implementing Monitoring, Elasticity, and High Availability** | CloudWatch, ELB, ASG, Route 53 | **High** |

## OUT OF SCOPE — do not spend revision time here
| # | Module | Why it matters |
|---|--------|----------------|
| 11 | Automating Your Architecture | **CloudFormation is NOT in the test** |
| 12 | Caching Content | CloudFront, ElastiCache |
| 13 | Building Decoupled Architectures | SQS, SNS |
| 14 | Building Serverless Architectures and Microservices | Lambda, API Gateway |
| 15 | Data Engineering Patterns | Kinesis, Athena, Redshift |
| 16 | Planning for Disaster | **RTO/RPO and DR strategies live here, not Module 10** |
| 17 | Bridging to Certification | SAA-C03 exam prep |
| – | Capstone Project | – |

## Two things this structure tells us
1. **Security is taught twice and is worth a lot.** Module 3 (foundations) and
   Module 9 (applications and data) are both in scope. Roughly a fifth of the
   examinable material is security — weight your revision accordingly.
2. **No CloudFormation and no disaster recovery.** Both sit just past the
   boundary at Modules 11 and 16. Anything about templates, `!Ref`/`!GetAtt`,
   RTO/RPO or pilot-light architectures is coursework, not test material.

## The architecture Modules 1–10 build up to

```
                        Internet
                            |
                     [Internet Gateway]
                            |
        +-------------------+-------------------+
        |       Application Load Balancer       |   <- Module 10
        |        (public subnets, 2+ AZs)       |
        +-------------------+-------------------+
                            |
        +-------------------+-------------------+
        |          Auto Scaling Group           |   <- Module 10
        |        EC2 web servers                |   <- Module 5
        |        private subnets, 2 AZs         |   <- Module 7
        +-------------------+-------------------+
                |                        |
        [RDS Multi-AZ]              [S3 bucket]      <- Modules 6 and 4
         private subnets            static assets
                |
   Access governed by IAM users, roles and policies   <- Modules 3 and 9
   Data protected by KMS / Secrets Manager            <- Module 9
   Other networks joined by peering / VPN / DX        <- Module 8
```

Most ACA practicals are a subset of that diagram. Build it end to end and
explain each arrow, and you are in distinction territory.

## Suggested order for covering Modules 1–10
1. **Module 7 (VPC)** — everything else sits inside the network.
2. **Module 5 (EC2)** — plus security groups, reinforcing Module 7.
3. **Module 3 (Securing Access)** — IAM foundations.
4. **Module 9 (Securing User, App, Data)** — builds directly on Module 3.
5. **Module 10 (Monitoring, Elasticity, HA)** — combines 5, 7 and 9.
6. **Module 4 (S3)** and **Module 6 (Database)** — storage and data layers.
7. **Modules 2 and 8** — concept-level review last.
   *(Module 8's peering lab is already done — see `08-connecting-networks.md`.)*
