# Module 3 — Securing Access

**Status:** not started | **Confidence:** –
**Note:** this course teaches security in two passes. Module 3 is the
**foundation** (who you are, how you authenticate, basic permissions).
Module 9 is the **advanced** pass (application access, roles in depth, data
encryption). Expect both to be examinable.

## Scope
The AWS account, root user protection, IAM identities, and the basics of
permission policies.

## Key concepts to know cold
- **Root user:** created with the account, has unrestricted access, identified
  by the account email. **Lock it away**: enable MFA, do not create access keys
  for it, never use it for daily work. Create an IAM admin user instead.
- **The few things only the root user can do:** change account settings, close
  the account, change or cancel support plans, restore an IAM user's
  permissions if they lock everyone out.
- **IAM identities:**
  - **User** — a person or application; long-term credentials.
  - **Group** — a container of users used to attach permissions. Groups are
    **not** principals, cannot be nested, and cannot be referenced in a policy.
  - **Role** — no long-term credentials; **assumed** temporarily by a user, an
    AWS service, or a federated identity. The right answer whenever a *service*
    needs access.
- **Two credential types:** console password (+MFA) for humans, **access key ID
  and secret access key** for programmatic/CLI access. A secret access key is
  shown **once** at creation — if lost, rotate rather than recover.
- **Authentication vs authorization:** authentication = proving who you are
  (password, access key, MFA). Authorization = what that identity may do
  (policies).
- **Policies** are JSON documents attached to identities or resources.
  Structure: `Version`, `Statement[]` with `Effect`, `Action`, `Resource`
  (and `Principal` on resource-based policies, `Condition` optionally).
- **Evaluation logic:** everything is denied by default (implicit deny); an
  **Allow** grants access; an **explicit Deny always wins** over any Allow.
- **AWS-managed vs customer-managed vs inline policies:** AWS-managed are
  maintained by AWS (convenient, often too broad), customer-managed are yours
  and reusable, inline are embedded in one identity and disappear with it.
- **Principle of least privilege:** grant only the actions and resources needed.
  Start closed, open deliberately.
- **Security best practices:** MFA everywhere, rotate access keys, no hardcoded
  credentials in code or user data, use roles for EC2/applications, use the
  credential report and IAM Access Analyzer to audit.

## Typical AWS Academy lab
An **Introduction to IAM**-style guided lab: explore pre-created users and
groups, attach managed policies, and observe how a user's effective permissions
change as they are added to or removed from groups — including seeing an action
denied before the policy is attached and permitted afterwards.

## High-yield gotchas (marks lost here)
- **Groups are not principals.** You cannot write `"Principal": "…:group/Devs"`
  in a bucket policy. Grant to users or roles.
- **An explicit Deny cannot be overridden** — not even by an AdministratorAccess
  policy on the same identity.
- Permissions are **cumulative** across all attached policies (group + user +
  inline), then filtered by any explicit Deny.
- IAM is a **global** service — users, groups, roles and policies are not
  Region-specific.
- Do **not** answer "create an IAM user for the application" — an application
  running on AWS should use a **role**.

## Self-check questions
1. Which four things can only the root user do?
2. A user is in a group allowing `s3:*` and also has an inline policy denying
   `s3:DeleteBucket`. What can they do?
3. When is a role the right answer instead of a user?
4. Why is IAM described as a global service?

## My notes
_(fill in as we go)_
