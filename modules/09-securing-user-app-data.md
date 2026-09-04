# Module 9 — Securing User, Application, and Data Access

**Status:** not started | **Confidence:** – (Knowledge Check: 100/100)
**PRIORITY MODULE — policy JSON is very commonly hand-written in a practical.**

## Scope
The advanced security pass: least-privilege policy authoring, giving
**applications** access via roles, federating **users**, and protecting **data**
with encryption and secret storage. (Module 3 covered the identity foundations.)

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
- **Extras:** MFA, permission boundaries, IAM Access Analyzer, password
  policies, access key rotation, credential report.

## Securing *user* access (federation)
- **IAM Identity Center (formerly AWS SSO):** central place to manage workforce
  access across multiple accounts.
- **Identity federation:** let users sign in with an existing identity provider
  instead of creating IAM users. SAML 2.0 for corporate directories,
  **AWS Directory Service** for Microsoft AD, **Amazon Cognito** for web and
  mobile **application** users (user pools = sign-up/sign-in, identity pools =
  temporary AWS credentials).
- All federation ultimately works by **assuming a role via AWS STS** to get
  temporary credentials.

## Securing *data* access (encryption and secrets)
- **Encryption at rest vs in transit.** In transit = TLS/HTTPS. At rest =
  encrypting the stored bytes.
- **AWS KMS:** managed keys for encryption across AWS services.
  - **AWS-managed keys** (created and rotated by AWS per service) vs
    **customer-managed keys** (you control the key policy, rotation, and can
    disable or schedule deletion).
  - A **key policy** is a resource-based policy on the key. A user needs
    permission on **both** the key and the encrypted resource.
  - **Envelope encryption:** KMS encrypts a data key, the data key encrypts the
    data. This is why KMS never sees your bulk data.
- **S3 encryption options:** SSE-S3, SSE-KMS (audit trail via CloudTrail),
  SSE-C, plus client-side encryption.
- **AWS Secrets Manager:** stores credentials (e.g. DB passwords) and can
  **automatically rotate** them. Use instead of hardcoding a password in code
  or a config file.
- **Systems Manager Parameter Store:** configuration values and secrets
  (SecureString). Cheaper than Secrets Manager, but **no automatic rotation** —
  that difference is the usual exam discriminator.
- **AWS Certificate Manager (ACM):** provision and auto-renew TLS certificates
  for ELB/CloudFront.

## Typical AWS Academy lab
Writing a **least-privilege policy** for a specific job (for example, allowing a
user to manage only EC2 instances carrying a particular tag, or read-only access
to a single bucket), and/or securing application data with **KMS encryption**
and **Secrets Manager**.

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
5. Secrets Manager or Parameter Store for a database password that must rotate
   every 30 days — and why?
6. What is envelope encryption, and why does KMS use it?

## My notes
_(fill in as we go)_
