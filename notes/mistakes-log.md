# Mistakes and Weak Areas Log

Anything answered wrongly, half-remembered, or confused goes here so it can be
re-drilled in a later session. Claude: check this file at the start of every
session and re-test these before moving on.

| Date | Module | What went wrong | Correct answer | Re-tested? |
|------|--------|-----------------|----------------|------------|
| 2026-09-04 | 9 | Cognito lab: put the **full** domain into `COGNITO_DOMAIN_STR`, producing a doubled hostname (`...amazoncognito.com.auth.us-east-1.amazoncognito.com`) and `DNS_PROBE_FINISHED_NXDOMAIN` on login | `COGNITO_DOMAIN_STR` takes the **prefix only** (e.g. `us-east-1dozamunkd`); the app appends `.auth.<region>.amazoncognito.com`. Same trap as `CLOUDFRONT_DISTRO_STR` (prefix) vs `BASE_NODE_SERVER_STR` (full URL) | no |
| 2026-09-04 | 9 | Ran `npm start` after `cp package2.json package.json` without replacing `<cognito-user-pool-id>`; shell read `<...>` as input redirection → `sh: line 1: cognito-user-pool-id: No such file or directory` | Copying the template file **resets** it — the placeholder edit must come after the `cp`. Server files need a restart; website files need a re-upload to S3 | no |
| 2026-09-04 | 9 (ties to 4) | Navigated directly to `/report` and got an S3 `<Error>AccessDenied` | Protected pages are rendered by the app/node server, not standalone S3 objects. S3 says AccessDenied rather than NoSuchKey when `s3:ListBucket` is not granted | no |
| 2026-09-04 | 10 | Unclear why the DB security group rule uses port 3306 when the traffic *comes from* the app EC2 | The port in an inbound rule is the **destination** port — the port the RECEIVER listens on, not anything about the sender. MySQL listens on 3306, so the DB accepts on 3306. The sender's source port is a random ephemeral port (1024-65535) chosen per connection and is never configured. Stateful SGs allow the reply automatically; stateless NACLs are why ephemeral ranges must be opened there. | no |

## 2026-09-08 — Module 10 challenge lab, inspection questions (3 marks lost)
**Claude's error, not the user's.** I answered the inspect-the-environment
questions from *design intent* ("private subnets **should** reach the internet,
so: Yes") instead of from the environment's **current state**. Graded result:
Q1 0/1, Q4 0/1, Q5 0/1.

- **Q4** "Should an instance in Private Subnet 2 reach the internet?" → **No**.
  Despite the word *should*, it is asking what the route table says today, and
  Private Subnet 2 has no NAT route yet.
- **Q5** "Can you connect to CafeWebAppServer from the internet?" → **No**.
  I assumed the "before" picture was a public single server. It is not:
  **CafeWebAppServer is in a private subnet**, which is precisely why the lab
  has you build an ALB to front it.
- **Q1** CafeSG ports → **not** "80 and 443". Read the Inbound rules tab.

**Rule taken forward: on any "inspect the environment" question, open the
console and look. Never infer the answer from what a correct architecture
would have — the lab is testing observation, and the environment is
deliberately imperfect.**

## 2026-09-08 — "the port belongs to the receiver" (RECURRING — second time)
Asked whether `db-sg` should allow **port 80** because the traffic comes from
`app-sg`. **No — `db-sg` allows 3306**, because MySQL is what is listening there.

A security group rule has **two independent fields**:
- **Port** = which service *on the receiver* may be reached → decided by **what
  software runs on the receiver**.
- **Source** = who may reach it → decided by **who the sender is** (inside the
  VPC: another **security group**; outside: a **CIDR**).

| SG (receiver) | Running on it | Port | Source |
|---|---|---|---|
| `web-sg` (ALB) | HTTP listener | **80** | Anywhere-IPv4 |
| `app-sg` (app server) | web app over HTTP | **80** | `web-sg` |
| `db-sg` (MySQL) | **MySQL** | **3306** | `app-sg` |

The app tier's 80 is a coincidence of it being a web app — it is **not inherited
from the sender**. If the app listened on 8080, that row would say 8080 and
`db-sg` would still say 3306.

**Two questions to ask for every rule:**
1. What is this thing listening on? → the **port** (80 HTTP, 443 HTTPS, 22 SSH,
   3306 MySQL, 5432 PostgreSQL, 2049 NFS/EFS).
2. Who is allowed to talk to it? → the **source**.

Has now come up twice. Re-drill before any security-group task.

## 2026-09-08 — Launch template v2 created blank (user data lost)
**Symptom:** both target group targets `Unhealthy — Health checks failed`, while
the instances themselves showed `2/2 checks passed`. ALB returned **502**.

**Cause:** a new launch template version was created to fix a tag, but
**"Source template version" was not set**, so the form started **blank** — the
new version had **no user data and no security group**. Instances launched fine
and passed EC2 status checks; nothing was listening on port 80.

**Fix:** Modify template (Create new version) → **set Source template version = 1**
→ re-add the tag → save → ASG → Edit → Version = Latest → **terminate the
instances** so replacements use it.

**RULE: when creating a new launch template version, ALWAYS set "Source template
version" first.** Otherwise you silently lose every field.

**Diagnostic pattern (same as the Lambda "undeployed code" one):** instance
status checks passing tells you the *machine* is healthy, not that the *app* is.
- **2/2 checks passed + target unhealthy** → the machine is fine, the app is not.
- ALB **502** = target reached, no valid HTTP response (app not listening).
- ALB **503** = no registered/healthy targets at all.
- ALB **504** = target reached but timed out.
