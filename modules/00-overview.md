# Coverage Map — Modules 1 to 10

Scope confirmed by lecturer: the practical test covers **Modules 1–10** of
AWS Academy Cloud Architecting (ACAv3), which aligns to AWS Solutions
Architect – Associate (SAA-C03).

| # | Module | Core services | Weight in a practical |
|---|--------|---------------|-----------------------|
| 1 | Welcome / course intro | – | Low (context only) |
| 2 | Introducing Cloud Architecting | Well-Architected Framework | Low–Med (justification) |
| 3 | Adding a Storage Layer | **S3** | **High** |
| 4 | Adding a Compute Layer | **EC2**, EBS, AMI, user data | **High** |
| 5 | Adding a Database Layer | **RDS**, DynamoDB, ElastiCache | Medium |
| 6 | Creating a Networking Environment | **VPC**, subnets, IGW, NAT, SG/NACL | **High** |
| 7 | Connecting Networks | Peering, TGW, VPN, Direct Connect | Medium |
| 8 | Securing User and Application Access | **IAM** users/roles/policies | **High** |
| 9 | Elasticity, HA and Monitoring | **ALB, ASG**, CloudWatch, Route 53 | **High** |
| 10 | Automating Your Architecture | **CloudFormation** | Medium–High |

## The architecture these modules build up to

```
                        Internet
                            |
                     [Internet Gateway]
                            |
        +-------------------+-------------------+
        |            Application Load Balancer  |     <- Module 9
        |         (public subnets, 2+ AZs)      |
        +-------------------+-------------------+
                            |
        +-------------------+-------------------+
        |          Auto Scaling Group           |     <- Module 9
        |     EC2 web servers (Module 4)        |
        |        private subnets, 2 AZs         |     <- Module 6
        +-------------------+-------------------+
                |                        |
        [RDS Multi-AZ]              [S3 bucket]        <- Modules 5 and 3
         private subnets            static assets
                |
   All access governed by IAM roles and policies       <- Module 8
   Whole stack deployable as a CloudFormation template  <- Module 10
   Networks joined by peering / VPN / DX                <- Module 7
```

Almost every ACA practical is some subset of that diagram. If you can build it
end to end and explain each arrow, you are in distinction territory.

## Suggested drilling order
1. **Module 6 (VPC)** — everything else sits inside it.
2. **Module 4 (EC2)** — plus security groups, which reinforce Module 6.
3. **Module 8 (IAM)** — policy JSON writing.
4. **Module 9 (ALB + ASG)** — combines 4, 6 and 8.
5. **Module 3 (S3)** and **Module 5 (RDS)** — the storage and data layers.
6. **Module 10 (CloudFormation)** — expresses all of the above as code.
7. **Modules 2 and 7** — concept-level review last.
