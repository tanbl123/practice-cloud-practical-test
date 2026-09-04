# Module 8 — Securing User and Application Access (IAM)

**Status:** not started | **Confidence:** – (Knowledge Check: 100/100)
**PRIORITY MODULE — policy JSON is very commonly hand-written in a practical.**

## Scope
Identity, permissions, and least-privilege policy authoring.

## Key concepts to know cold
- **Principals:** root user (lock away, MFA, never use daily), IAM users,
  groups (permission containers — groups cannot be nested and are not principals),
  **roles** (temporary credentials, assumed by users, services or federated identities).
- **Policy types:** identity-based (attached to user/group/role) vs
  resource-based (attached to the resource, e.g. an S3 bucket policy — these
  have a **`Principal`** element).
- **Policy JSON structure:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "OptionalLabel",
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::cafe-bucket/*",
    "Condition": {"IpAddress": {"aws:SourceIp": "10.0.0.0/16"}}
  }]
}
```
- **Evaluation logic (memorise):** explicit **Deny** > explicit **Allow** >
  implicit deny (default). Anything not explicitly allowed is denied.
- **Roles for EC2:** create role → attach policy → attach as **instance profile**
  to the instance. The app then gets temporary credentials from instance
  metadata. **Never hardcode access keys.**
- **STS AssumeRole:** temporary credentials; the basis of cross-account access
  and federation.
- **ARN format:** `arn:partition:service:region:account-id:resource`
  (S3 omits region and account: `arn:aws:s3:::bucket/key`).
- **Extras:** MFA, permission boundaries, IAM Access Analyzer, IAM Identity
  Center (SSO), password policies, access key rotation, credential report.

## Typical AWS Academy lab
Exploring users/groups/policies and their effective permissions, and writing a
**least-privilege policy** — often "allow this user to manage only EC2
instances tagged X" or "read-only access to one bucket".

## High-yield gotchas (marks lost here)
- **`"Resource": "arn:aws:s3:::bucket"`** allows bucket-level actions
  (`s3:ListBucket`). **`".../bucket/*"`** allows object-level actions
  (`s3:GetObject`). Most real policies need **both entries**.
- An explicit Deny anywhere always wins — even against an Administrator policy.
- Users get permissions from groups; **roles are assumed**, not attached to users.
- Least privilege means naming specific actions and specific resources —
  `"Action": "*"` or `"Resource": "*"` in an answer usually loses the mark.
- Service-to-service access = a **role**, not an IAM user with access keys.

## Self-check questions
1. Write a least-privilege policy: read-only on bucket `cafe-data`, including listing it.
2. User is in a group with S3 full access, but has an attached policy denying
   `s3:DeleteObject`. Can they delete? Why?
3. An EC2 app needs to write to DynamoDB. Exact steps?
4. Difference between a bucket policy and an IAM policy granting the same access?

## My notes
_(fill in as we go)_
