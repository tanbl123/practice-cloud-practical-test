# AWS Academy Cloud Architecting — Practice Support

Primary study path: the **AWS Academy Cloud Architecting (ACAv3)** labs in Canvas.
This repo holds an *optional* offline AWS sandbox for rehearsing CLI commands
without consuming AWS Academy lab time.

## Offline AWS sandbox (optional)

Runs a local simulated AWS (moto) so the real `aws` CLI works with no account,
no credentials and no cost.

```bash
./scripts/start.sh          # start simulated AWS on http://127.0.0.1:5000
./bin/awslocal s3 mb s3://my-bucket
./bin/awslocal s3 ls
./bin/awslocal ec2 create-vpc --cidr-block 10.0.0.0/16
./scripts/reset.sh          # wipe everything, start clean
./scripts/stop.sh
```

`bin/awslocal` takes exactly the same arguments as `aws`.

### First-time setup
```bash
python3 -m venv .venv && ./.venv/bin/pip install "moto[server]" awscli
```

### What it supports well
S3, EC2, VPC/subnets/route tables/security groups, IAM, ELBv2, Auto Scaling,
SQS, SNS, DynamoDB, CloudWatch, CloudFormation (partial).

### What it does not do
Real Lambda code execution, real RDS engines, the AWS Console UI, or anything
requiring genuine AWS networking. Use the AWS Academy lab environment for those.

---

## Repo layout

| Path | Purpose |
|------|---------|
| `PROGRESS.md` | **Current status, next step, session log** — read this first |
| `modules/00-overview.md` | Coverage map for Modules 1–10 and drilling order |
| `modules/*.md` | Per-module notes: concepts, labs, gotchas, self-check questions |
| `notes/mistakes-log.md` | Wrong answers to re-drill |
| `notes/exam-tips.md` | Cross-module high-yield points |
| `CLAUDE.md` | Instructions so a future Claude session resumes correctly |
| `bin/`, `scripts/` | Optional offline AWS CLI sandbox |
