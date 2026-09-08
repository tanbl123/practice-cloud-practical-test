# Console click paths — read this the morning of the test

One page per service. Exact screen sequence, and the setting that carries the
marks. Covers every buildable service in Modules 1-10 plus DynamoDB.

---

## VPC from scratch (Module 7)
```
VPC → Your VPCs → Create VPC
      VPC only · Name · IPv4 CIDR 10.0.0.0/16 → Create

VPC → Subnets → Create subnet
      select VPC · Name · Availability Zone · CIDR 10.0.0.0/24
      "Add new subnet" for each one — set a DIFFERENT AZ for HA

VPC → Internet gateways → Create internet gateway → Name → Create
      then Actions → ATTACH TO VPC          ← two separate actions

VPC → Route tables → Create route table (Name, VPC)
      Routes tab → Edit routes → Add route
          0.0.0.0/0 → Internet Gateway
      Subnet associations tab → Edit subnet associations
          tick the PUBLIC subnets                ← MOST MISSED STEP

VPC → NAT gateways → Create NAT gateway
      Name · Subnet = a PUBLIC subnet · Connectivity = Public
      · Allocate Elastic IP → Create

VPC → Route tables → Create route table (private)
      Routes → Edit routes → 0.0.0.0/0 → NAT Gateway
      Subnet associations → tick the PRIVATE subnets   ← MOST MISSED STEP
```
**Marks:** subnet associations · NAT in a *public* subnet · 2 AZs if "highly available".

---

## EC2 instance (Module 5)
```
EC2 → Instances → Launch instances
      Name
      AMI: Amazon Linux 2023
      Instance type: t2.micro
      Key pair: vockey (or Proceed without)
      Network settings → EDIT:
          VPC · Subnet · Auto-assign public IP: Enable (if public)
          Security group: create new / select existing
      Configure storage: size, type, Encrypted (must be set at launch)
      Advanced details:
          IAM instance profile   ← how an app gets AWS permissions
          User data (bottom)     ← #!/bin/bash script, runs once at first boot
      → Launch instance
```
**Marks:** user data starts `#!/bin/bash` · IAM **role**, never access keys ·
public IP only where required.

---

## Security group chained to another SG (Modules 5, 7, 10)
```
EC2 → Security Groups → Create security group
      Name · Description · VPC
      Inbound rules → Add rule
          Type (HTTP / MYSQL-Aurora / SSH / All ICMP - IPv4)
          Source: Custom → type "sg-" → PICK THE OTHER SECURITY GROUP
      → Create
```
**Marks:** tier-to-tier source is a **security group**, not a CIDR.
Trick: create all SGs empty first, then add rules.

---

## S3 bucket + static website (Module 4)
```
S3 → Create bucket
     Region · globally-unique name
     Block Public Access: UNCHECK (type "confirm") if it must be public
     Bucket Versioning: Enable (REQUIRED for replication)
     → Create bucket

Objects tab → Upload → Add files → Upload

Properties tab → Static website hosting → Edit → Enable
     Index document: index.html   → Save
     (the WEBSITE endpoint appears at the bottom of this page)

Permissions tab → Bucket policy → Edit → paste → Save
```
Public-read policy:
```json
{"Version":"2012-10-17","Statement":[{"Sid":"PublicRead","Effect":"Allow",
"Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::BUCKET/*"}]}
```
**Marks:** the **`/*`** on the resource ARN · Block Public Access off ·
use the **website endpoint**, not the REST endpoint.

---

## DynamoDB table (Module 6 — confirmed extra)
```
DynamoDB → Tables → Create table
     Table name
     Partition key + type (String / Number / Binary)
     Sort key — ONLY if the brief asks
     Table settings: Default settings
         (Customize → Capacity mode: On-demand | Provisioned)
     → Create table

Explore table items → Create item → add attributes → Create item
```
**Marks:** sort key only if asked · On-demand = unpredictable traffic ·
GSI to query a non-key attribute.

---

## RDS database (Module 6)
```
RDS → Subnet groups → Create DB subnet group    ← needs 2+ AZs, do this first
RDS → Databases → Create database
     Standard create · Engine (MySQL / PostgreSQL)
     Templates: Dev/Test
     DB instance identifier · master username / password
     Instance configuration: db.t3.micro
     Availability: "Create a standby instance" = MULTI-AZ
     Connectivity: VPC · DB subnet group · Public access = NO
                   VPC security group (allow 3306 from the app SG)
     Additional configuration: initial database name, backups, encryption
     → Create database
```
**Marks:** private subnets · Public access **No** · Multi-AZ = availability,
read replica = performance · encryption chosen at creation.

---

## ALB + Auto Scaling (Module 10)
```
1. AMI:  EC2 → Instances → select → Actions → Image and templates → Create image

2. TARGET GROUP first:
   EC2 → Target Groups → Create target group
        Instances · Name · VPC
        Health checks → Advanced: healthy threshold 2, interval 10
        → Next → (skip registering) → Create

3. EC2 → Load Balancers → Create → Application Load Balancer
        Name · Internet-facing
        VPC · Mappings: tick TWO AZs and their PUBLIC subnets   ← HA
        Security group: HTTP/HTTPS from 0.0.0.0/0 (remove the default SG)
        Listener HTTP:80 → forward to the target group
        → Create

4. EC2 → Launch Templates → Create launch template
        Name · "Provide guidance for EC2 Auto Scaling"
        My AMIs → your AMI · t2.micro · key pair · security group
        Advanced: IAM instance profile · Detailed CloudWatch monitoring
                  · User data
        → Create

5. Launch template → Actions → Create Auto Scaling group
        Name · template
        VPC · Subnets: the PRIVATE subnets in TWO AZs             ← HA
        Attach to an existing load balancer → your target group
        Turn ON Elastic Load Balancing health checks
        Health check grace period: 90-300 s        ← lets user data finish
        Enable group metrics collection
        Desired / Min / Max
        Scaling policy: Target tracking, CPU 50%  (if asked to scale)
        → Create
```
**Marks:** 2 AZs for BOTH the ALB and the ASG · **ELB** health checks not EC2 ·
grace period · instance SG allows :80 **from the ALB's SG**.

---

## IAM user / group / policy (Module 3)
```
IAM → User groups → Create group → name → attach policies
IAM → Users → Create user → name → Add to group → Create
IAM → Policies → Create policy → JSON tab → paste → Next → name → Create
IAM → Roles → Create role → AWS service → EC2 → attach policy → name
```
Least-privilege shape:
```json
{"Version":"2012-10-17","Statement":[{"Effect":"Allow",
"Action":["s3:GetObject","s3:ListBucket"],
"Resource":["arn:aws:s3:::BUCKET","arn:aws:s3:::BUCKET/*"]}]}
```
**Marks:** named actions, named ARNs, never `*` · bucket ARN **and** `/*` ARN ·
service access = a **role**.

---

## KMS + encrypted EBS volume (Module 9)
```
KMS → Customer managed keys → Create key
      Symmetric · Encrypt and decrypt · Alias
      Key administrators: your role · Key users: your role → Finish

EC2 → Volumes → Create volume
      Type · Size · Availability Zone = SAME AZ AS THE INSTANCE   ← required
      Encryption: Encrypt this volume · KMS key: your key → Create
      select volume → Actions → Attach volume → instance
```
**Marks:** same AZ · encryption at creation (cannot be added later) ·
disabling the key immediately breaks access.

---

## EFS (Module 5)
```
EFS → Create file system → Name · VPC → (Customize for classes/encryption)
      → Create
      Network tab → mount targets: one per AZ, each with a security group
```
**Marks:** mount target SG must allow **NFS 2049 from the EC2 instances' SG** ·
a mount target in every AZ.

---

## VPC peering (Module 8)
```
VPC → Peering connections → Create peering connection
      Name · Requester VPC · Accepter VPC → Create
      Actions → ACCEPT REQUEST            ← status must read Active

VPC → Route tables → (VPC-A's table) → Edit routes
      destination = VPC-B's CIDR → target = the peering connection
                  ... AND THE SAME IN VPC-B's ROUTE TABLE       ← both sides
```
**Marks:** accept the request · routes on **both** sides · non-overlapping CIDRs.

---

## CloudWatch alarm → SNS (Module 10)
```
SNS → Topics → Create topic → Standard → name → Create
      → Create subscription → Email → address → CONFIRM VIA EMAIL

CloudWatch → Alarms → Create alarm → Select metric
      (EC2 → Per-Instance → CPUUtilization)
      Threshold · Period
      Notification → send to your SNS topic → name → Create
```
**Marks:** the subscription must be **confirmed** · memory and disk are NOT
default EC2 metrics (need the CloudWatch agent).

---

## Final 60-second check before submitting any task
1. Route table **Subnet associations** tab — not just the route
2. **Two AZs** wherever "highly available" appears
3. Tier-to-tier SG sources are **security groups**
4. Names match the brief **exactly**
5. Actually load the URL / check target health
6. Old rules **deleted** where the brief said replace
