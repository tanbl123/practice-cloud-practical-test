# Practical test format — CONFIRMED by lecturer (2026-09-07)

**Date: 9 September 2026. Scope: Modules 1-10, PLUS DynamoDB.**

- **4 tasks**
- **Each task covers a DIFFERENT service** (examples given: task 1 Auto Scaling,
  task 2 VPC)
- Tasks are **independent**, not one connected build

## What this format means for strategy
1. **A failure does not cascade.** Each task is scored on its own, so a task you
   cannot finish costs only that task. Never let one task eat the clock.
2. **Budget the time evenly** — roughly (total time ÷ 4) per task. If a task
   overruns its slice, leave it and move on; come back only at the end.
3. **Do the task you are most confident on FIRST**, to bank marks early.
4. Expect each task to be a **small self-contained build**, not a full
   three-tier architecture. Think "create a VPC with public and private subnets"
   rather than "build the entire café application".

## Services confirmed / likely
| Likelihood | Service | Module |
|---|---|---|
| **Confirmed** | Auto Scaling (+ ALB) | 10 |
| **Confirmed** | VPC (subnets, IGW, NAT, route tables) | 7 |
| **Confirmed** | **DynamoDB** | 6 |
| Likely 4th | S3 / EC2 / IAM | 4 / 5 / 3 |

## Revision priority given this format
1. **VPC build from scratch** — `notes/build-order.md` steps 1-6
2. **ALB + Auto Scaling build** — launch template, target group, 2 AZs
3. **DynamoDB table creation** — see `modules/06-database-layer.md`
4. **S3 bucket + policy / static hosting**, **EC2 launch + user data + SG**,
   **IAM policy JSON**
