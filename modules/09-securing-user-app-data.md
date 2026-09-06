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

---

# Confirmed lab: Securing Applications by Using Amazon Cognito

*(Course numbering confirmed 2026-09-04: this is the Module 9 guided lab. ~60 min.)*

## The one concept this lab exists to teach

| | **User pool** | **Identity pool** |
|---|---|---|
| Answers | "Who are you?" | "What AWS resources may you use?" |
| Job | **Authentication (authN)** | **Authorization to AWS (authZ)** |
| Is a | user directory (sign-up/sign-in) | credential broker |
| Returns | **JWT tokens** (ID / access / refresh) | **temporary AWS credentials** via STS |
| Backed by | its own user store, or federated IdP | an **IAM role** |

**Flow:** user signs in → **user pool** issues a JWT → app passes the JWT to the
**identity pool** → identity pool validates it and calls **STS** → app receives
temporary AWS credentials → app calls **DynamoDB** with them.

The exam-ready sentence: *a user pool authenticates people; an identity pool
turns that proven identity into temporary AWS credentials tied to an IAM role.*

## Architecture built in the lab
- Birds web app: static site in an **S3 bucket**, served through **CloudFront**,
  with a **NodeJS** API server on **Cloud9**.
- Protected pages (sightings, report, siteadmin) require authentication.
- The `Administrators` **group** in the user pool drives role-based access to
  the admin page.
- The admin page queries a **DynamoDB** table (`BirdSightings`) using the
  temporary credentials from the identity pool.

## Six values to record (this is most of the lab's difficulty)
```
S3 bucket:                    (from setup.sh output)
CloudFront distribution:      d123456acbdef.cloudfront.net
User pool ID:                 us-east-1_AAAA1111
App client ID:                1a1a1a12b2b2b2b3c3c3c3c
Cognito domain prefix:        us-east-1ozkgdmcoh
Identity pool ID:             us-east-1:xxxx-xxxx-...
```
Mixing these up is the single biggest time sink in this lab.

## Key configuration details
- **Callback URL** must be exactly `https://<cloudfront-domain>/callback.html`.
- **OAuth 2.0 grant types:** authorization code grant + implicit grant.
  *Authorization code grant is the secure/recommended one* (the token is
  exchanged server-side); implicit grant returns the token in the URL fragment
  and is legacy.
- **OpenID Connect scopes:** Email and OpenID (clear Phone).
- **Authentication flow:** `ALLOW_USER_PASSWORD_AUTH` only.
- **Cognito domain prefix** = only the part between `//` and
  `.auth.us-east-1.amazoncognito.com`.
- Tokens are stored in **browser local storage**, default expiry **3600 s**.
- Identity pool: add the **user pool + app client** as an identity provider;
  authenticated users get the **default authenticated role**.

## Traps in this lab (where time is lost)
1. **Two different formats of the CloudFront value in the same file.**
   `BASE_NODE_SERVER_STR` needs the **full** `https://d123456.cloudfront.net`,
   but `CLOUDFRONT_DISTRO_STR` needs **only the prefix** `d123456`.
2. **In `auth.js` the `Logins` key takes the USER pool ID, not the identity
   pool ID** — the lab flags this in bold for good reason. The key format is
   `cognito-idp.<region>.amazonaws.com/<user-pool-id>`.
3. **Every website edit must be re-uploaded to S3.** Editing `config.js` in
   Cloud9 changes nothing until you re-run the `aws s3 cp website s3://... 
   --recursive` command. Testing stale code is the classic failure.
4. **The node server must be restarted** (Ctrl+C, then `npm start`) after
   `package.json` changes.
5. The lab text renders the cache-control flag with a line break —
   type it as `--cache-control "max-age=0"`, no space inside `max-age`.
6. **JWT errors → open a fresh browser tab/window.** A stale token in local
   storage causes confusing failures.
7. Admin-created users are in FORCE_CHANGE_PASSWORD state, so **expect a
   "change password" prompt** on first login for both users.
8. Wait for the **CloudFront distribution to reach `Enabled`** before testing.

## Users created
| User | Password | Group |
|---|---|---|
| `testuser` | `Lab-password1$` | – |
| `admin` | `Admin123$` | `Administrators` |

## Success criteria
- `testuser` logs in → SIGHTINGS page shows data (proves **user pool authN**).
- `admin` logs in → SITEADMIN page renders (proves **group-based access**).
- VALIDATE MY TEMPORARY AWS CREDENTIALS → *"Your Dynamodb Table has 0 rows"*
  (proves **identity pool authZ** to a real AWS service).

## Self-check questions
1. User pool or identity pool: authenticating a user? Calling DynamoDB?
2. What does the identity pool actually hand back, and which service mints it?
3. Why does `auth.js` need the user pool ID inside the `Logins` map?
4. How does the app know `admin` may see the admin page?
5. Authorization code grant vs implicit grant — which is preferred and why?

## Seen for real (2026-09-04): doubled Cognito domain
Symptom: clicking LOGIN goes to
`<prefix>.auth.us-east-1.amazoncognito.com.auth.us-east-1.amazoncognito.com/login?...`
and the browser shows **DNS_PROBE_FINISHED_NXDOMAIN**.

Cause: `CONFIG.COGNITO_DOMAIN_STR` was set to the **full** domain. The app
appends `.auth.<region>.amazoncognito.com` itself, so the suffix appears twice.

Fix: set it to the **prefix only**, re-upload the website to S3, hard-refresh.

**Rule for this file:** two of the four values are prefixes, one is a full URL.
```js
CONFIG.BASE_NODE_SERVER_STR   = "https://d123456.cloudfront.net";  // FULL URL
CONFIG.COGNITO_DOMAIN_STR     = "us-east-1abcdefg";                // PREFIX ONLY
CONFIG.CLOUDFRONT_DISTRO_STR  = "d123456";                         // PREFIX ONLY
```

---

# Confirmed lab 2: Encrypting Data at Rest by Using AWS Encryption Options

*(Module 9 also has a second guided lab, ~30 min: S3 default encryption + KMS + EBS + CloudTrail.)*

## The core concept: envelope encryption

```
KMS key (customer managed, symmetric, 256-bit, NEVER leaves KMS)
   |  encrypts
   v
Data key  --- stored ENCRYPTED alongside the EBS volume
   |  encrypts
   v
Your actual data on the volume
```

On attach: EC2 sends the **encrypted data key** to KMS → KMS checks the key policy
and IAM → returns the **plaintext data key** → EC2 holds it **in memory only** and
uses it for all reads/writes to that volume.

Why it is built this way: KMS never sees your bulk data (only tiny data keys),
and symmetric KMS keys never leave the service unencrypted.

## Task flow
1. **S3 default encryption** — upload `clock.png`, observe **SSE-S3** applied
   automatically. Open the object URL: it displays fine.
2. **Create KMS key** — Symmetric, alias `MyKMSKey`, `voclabs` as both key
   **administrator** and key **user**.
3. **Encrypted EBS volume** — 1 GiB, **same AZ as the instance**, encrypted with
   `MyKMSKey`, attach to `LabInstance`. Root volume (8 GiB) stays unencrypted.
4. **Disable the key** → detach → re-attach **fails**:
   *"The encrypted volume was unable to access the KMS key."* Re-enable → works.
5. **CloudTrail** — filter Event source = `kms.amazonaws.com`.
6. **Key rotation** — enable automatic annual rotation.

## Points that carry marks
- **Encryption at rest is not access control.** The `clock.png` object is
  encrypted on disk, yet anyone with the public object URL can view it — S3
  decrypts transparently for authorised requests. Confidentiality at rest and
  authorisation are separate controls.
- **SSE-S3 is applied to every new S3 object by default** (since Jan 2023). You
  do not have to turn it on.
- **Key administrators vs key users** are different things in a key policy.
  Administrators manage the key (and by default cannot use it to encrypt/decrypt);
  users perform cryptographic operations. Least privilege usually separates them.
- **Disabling a key immediately breaks access to everything encrypted with it**,
  and is instantly reversible. **Scheduling deletion has a mandatory waiting
  period (7-30 days)** and is irreversible once it completes — which is exactly
  why the waiting period exists.
- **You cannot encrypt an existing unencrypted volume in place.** The root volume
  stays unencrypted. To encrypt it: snapshot → copy the snapshot **with
  encryption enabled** → create a volume from the encrypted copy.
- **An EBS volume must be in the same AZ as the instance** (Module 5 tie-in).
- **Automatic rotation** is annual, and only for **symmetric KMS keys with key
  material generated by AWS**. Old key material is retained so previously
  encrypted data still decrypts; the key ID and alias do not change.

## CloudTrail events to recognise (all `kms.amazonaws.com`)
| Event | When it fires |
|---|---|
| `GenerateDataKeyWithoutPlaintext` | creating the encrypted volume — KMS mints the data key |
| `CreateGrant` | attaching — EC2 is granted permission to use the key |
| `Decrypt` | attaching — the encrypted data key is decrypted |
| `RetireGrant` | detaching — the grant is given up |
| `DisableKey` | you disabled the key |

CloudTrail **Event history keeps 90 days**. For longer retention, create a
**trail** (delivers to S3).

## Self-check questions
1. Explain envelope encryption in three sentences.
2. The object is encrypted at rest, so why can anyone open the object URL?
3. What breaks when you disable a KMS key, and how fast does it recover?
4. How do you encrypt an existing unencrypted EBS root volume?
5. Which CloudTrail event proves the instance was allowed to use the key?
