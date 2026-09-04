# Module 3 — Adding a Storage Layer (Amazon S3)

**Status:** not started | **Confidence:** –

## Scope
Object storage, bucket configuration, static website hosting, access control.

## Key concepts to know cold
- **Object storage:** bucket + key + object. Not a filesystem — flat namespace;
  "folders" are just key prefixes. Max object size 5 TB (multipart upload above 5 GB).
- **Durability:** 99.999999999% (11 nines) across S3 storage classes.
- **Storage classes:** Standard · Intelligent-Tiering · Standard-IA ·
  One Zone-IA · Glacier Instant Retrieval · Glacier Flexible Retrieval ·
  Glacier Deep Archive. IA classes have a retrieval fee and a minimum
  storage duration; One Zone-IA lives in a single AZ (cheaper, less resilient).
- **Lifecycle policies:** transition objects between classes / expire them by age.
- **Versioning:** protects against overwrite and delete; deletes create a
  *delete marker*. Once enabled it can only be suspended, never removed.
- **Encryption:** SSE-S3 (AWS-managed keys), SSE-KMS (KMS keys, audit trail),
  SSE-C (you supply the key). Encryption in transit via HTTPS/TLS.
- **Static website hosting:** enable on the bucket, set index and error
  documents, get a website endpoint.
- **Access control:** bucket policy (resource-based JSON), IAM policy
  (identity-based), ACLs (legacy), **Block Public Access** (overrides everything).
- **Pre-signed URLs:** time-limited access to a private object.

## Typical AWS Academy lab
Building the café's **static website** on S3: create a bucket, upload site
files, enable static website hosting, attach a bucket policy for public read,
turn off Block Public Access, then browse the website endpoint.

## High-yield gotchas (marks lost here)
- Bucket policy resource ARN needs the **`/*`** for objects:
  `"Resource": "arn:aws:s3:::my-bucket/*"`. Using `arn:aws:s3:::my-bucket`
  (no `/*`) grants bucket-level actions only and the website returns 403.
- **Block Public Access is ON by default** and silently overrides a permissive
  bucket policy. Website 403 → check this first.
- The **website endpoint** (`bucket.s3-website-<region>.amazonaws.com`) is not
  the same as the **REST endpoint** (`bucket.s3.amazonaws.com`). Static site
  routing/index documents only work on the website endpoint.
- Bucket names are **globally unique** across all AWS accounts, DNS-style
  lowercase.
- S3 gives strong read-after-write consistency now — old "eventual consistency"
  answers are outdated.

## Self-check questions
1. Write a bucket policy granting anonymous `s3:GetObject` on `cafe-site`.
2. Website returns 403 — list three things to check, in order.
3. Which storage class for backups accessed twice a year, retrieval in minutes acceptable?
4. Versioning is on; you delete an object. What actually happened, and how do you recover it?

## My notes
_(fill in as we go)_
