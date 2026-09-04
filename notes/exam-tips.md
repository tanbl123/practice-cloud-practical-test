# High-Yield Exam Tips

Cross-module points that decide marks. Add to this as the lecturer drops hints.

## The five most common lost marks (my prediction, revise as we learn more)
1. **Route table created but not associated** with the subnet (Module 6).
2. **Bucket policy ARN missing `/*`** for object-level actions (Modules 3, 8).
3. **Security group referencing a CIDR instead of another security group**
   for tier-to-tier traffic (Modules 4, 9).
4. **Only one AZ selected** for an ALB, ASG, or DB subnet group — kills the
   "highly available" requirement (Modules 5, 9).
5. **Health check path returns 404**, so ALB targets never go healthy (Module 9).

## Answer-shaping habits
- When a question says "highly available", your answer must contain
  **two or more Availability Zones**.
- When it says "least privilege", name **specific actions** and **specific
  resource ARNs** — never `*`.
- When it says "must not be reachable from the internet", the answer involves a
  **private subnet** and usually a **NAT gateway** for outbound updates.
- When it says "temporary credentials" or "service needs access", the answer is
  an **IAM role**, never an access key.
- When it says "decouple", think SQS/SNS; when it says "repeatable deployment",
  think CloudFormation.

## Practical-test technique
- Read every requirement and turn it into a checklist before touching the console.
- Name resources exactly as the brief specifies — markers often grep for names.
- After building, **verify**: hit the URL, check target health, confirm the
  route table associations tab, re-read the brief against what you built.
- If something doesn't work, troubleshoot in layers: routing → security group →
  NACL → application.
- Leave time to screenshot/record evidence if the brief asks for it.
