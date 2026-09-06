# High-Yield Exam Tips

Cross-module points that decide marks. Add to this as the lecturer drops hints.

## The five most common lost marks (my prediction, revise as we learn more)
1. **Route table created but not associated** with the subnet (Module 7).
2. **Bucket policy ARN missing `/*`** for object-level actions (Modules 4, 9).
3. **Security group referencing a CIDR instead of another security group**
   for tier-to-tier traffic (Modules 5, 10).
4. **Only one AZ selected** for an ALB, ASG, or DB subnet group — kills the
   "highly available" requirement (Modules 6, 10).
5. **Health check path returns 404**, so ALB targets never go healthy (Module 10).

## Diagnostic nuggets worth quoting in an answer
- **S3 returns `AccessDenied`, not `NoSuchKey`, for a missing object** when the
  caller lacks `s3:ListBucket`. It is deliberate: it stops anonymous callers
  probing which keys exist. So an S3 AccessDenied means *either* a permissions
  problem *or* a wrong key — check the path before rewriting the bucket policy.
- **An XML `<Error><Code>...` page means the response came from S3**, not from
  your application. Useful for telling which layer failed.
- **`DNS_PROBE_FINISHED_NXDOMAIN` means the hostname itself is malformed or does
  not exist** — a config/typo problem, never a permissions one.
- **Timeout vs connection refused:** a timeout points at routing (missing route,
  wrong route table); refused points at security groups, NACLs or the app.
- **"Success" is not "did the right thing."** A Lambda reporting 0 errors and
  100% success with a **~2 ms duration** did no real work — that is the default
  placeholder handler returning instantly because the code was never
  **Deployed** (Save is not Deploy). Localise a silent fault with two numbers:
  *invocations* (did it run at all?) then *duration* (did it run long enough to
  have done the work?).

## Answer-shaping habits
- When a question says "highly available", your answer must contain
  **two or more Availability Zones**.
- When it says "least privilege", name **specific actions** and **specific
  resource ARNs** — never `*`.
- When it says "must not be reachable from the internet", the answer involves a
  **private subnet** and usually a **NAT gateway** for outbound updates.
- When it says "temporary credentials" or "service needs access", the answer is
  an **IAM role**, never an access key.
- When it says "decouple" (SQS/SNS) or "repeatable deployment"
  (CloudFormation), note that those are Modules 13 and 11 — **outside the
  test scope**.

## Practical-test technique
- Read every requirement and turn it into a checklist before touching the console.
- Name resources exactly as the brief specifies — markers often grep for names.
- After building, **verify**: hit the URL, check target health, confirm the
  route table associations tab, re-read the brief against what you built.
- If something doesn't work, troubleshoot in layers: routing → security group →
  NACL → application.
- Leave time to screenshot/record evidence if the brief asks for it.
