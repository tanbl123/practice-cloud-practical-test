# Learner Lab teardown & budget guide

**Budget: $50 total for the Learner Lab.** Every practice task must end with a
teardown list. Resources **persist and keep billing between lab sessions** —
"End Lab" stops the session, it does not delete anything. Stopped ≠ free.

## What actually costs money (approx. us-east-1, per day if left running)

| Resource | ~per day | Note |
|---|---|---|
| **NAT gateway** | **~$1.10** | **#1 budget killer.** Hourly charge from creation, used or not. |
| **Application Load Balancer** | ~$0.55 | Hourly, idle or not. |
| EC2 t2.micro x2 (an ASG) | ~$0.55 | |
| RDS db.t3.micro | ~$0.40 | Plus storage. |
| Public IPv4 / Elastic IP | ~$0.12 each | Charged since Feb 2024 even when attached. |
| KMS customer managed key | ~$0.03 | $1/month. |
| EBS volumes | small, but **survive instance termination** | A stopped instance still bills for its disk. |
| DynamoDB (on-demand), S3 (small), IAM, VPC, SGs, route tables, launch templates | ~free | |

**NAT gateway + ALB left running = ~$1.65/day ≈ the entire budget in a month.**
If only two things get cleaned up, make it those two.

## Universal teardown order (reverse of the build order)

1. **Auto Scaling group** — set desired/min/max to 0, then **delete the ASG**
   (this terminates its instances). Terminating instances directly is pointless:
   the ASG just replaces them.
2. **Load balancer** → then its **target groups**.
3. **EC2 instances** — terminate strays. Then check **Volumes** for orphaned EBS.
4. **NAT gateways** — delete, **wait for state = Deleted**, *then* release the
   **Elastic IPs** (Elastic IPs → Actions → Release). Releasing first fails.
5. **RDS** — Delete, uncheck "create final snapshot", tick the acknowledgement.
   If it refuses, disable **deletion protection** via Modify first.
6. **VPC** — delete last; the console offers to remove subnets, route tables,
   IGW and endpoints along with it.
7. **S3** — **Empty** the bucket first (including **versions** if versioning was
   enabled), then Delete.
8. **KMS** — cannot be deleted immediately: **Schedule key deletion**, min 7 days.
9. **Commonly forgotten:** launch templates, AMIs (**Deregister**) and their
   **snapshots**, key pairs, CloudWatch alarms, SNS topics, EFS file systems,
   Cloud9 environments, VPC endpoints.

## End-of-session check (30 seconds)
EC2 dashboard should read **0** for: Instances (running), Volumes, Elastic IPs,
Load Balancers. VPC → **NAT Gateways** should read **0**.
Do this in **every Region you touched** — the console only shows one at a time.

## Per-task teardown log
| Task | Resources created | Teardown |
|---|---|---|
| `practice/dynamodb-q1.md` | DynamoDB table `CafeOrders` (+ GSI, PITR) | Delete the table; the GSI and PITR go with it. Cost ≈ $0. |
