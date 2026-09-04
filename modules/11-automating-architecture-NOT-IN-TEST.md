# Module 11 — Automating Your Architecture (CloudFormation)

> ## ⚠️ NOT IN THE PRACTICAL TEST
> Confirmed 2026-09-04: the test covers Modules 1-10, and CloudFormation is
> **Module 11**. Kept here for coursework reference only — do not spend
> revision time on it for the practical.

**Status:** not started | **Confidence:** –

## Scope
Infrastructure as Code: templates, stacks, and repeatable deployment.

## Key concepts to know cold
- **Why IaC:** repeatable, version-controlled, self-documenting, no manual
  drift, easy teardown of an entire environment.
- **Template sections** (YAML or JSON):

| Section | Required | Purpose |
|---|---|---|
| `AWSTemplateFormatVersion` | no | `'2010-09-09'` |
| `Description` | no | Free text |
| `Metadata` | no | Extra data / console grouping |
| `Parameters` | no | Inputs supplied at stack creation |
| `Mappings` | no | Lookup table (e.g. AMI per Region) |
| `Conditions` | no | Create resources only if a condition holds |
| `Transform` | no | Macros / SAM |
| **`Resources`** | **YES** | The actual AWS resources — the only required section |
| `Outputs` | no | Values returned (and optionally exported) |

- **Intrinsic functions:**
  - `!Ref` — a parameter's value, or a resource's *default* identifier
    (for EC2 = instance id, for a subnet = subnet id).
  - `!GetAtt` — a specific attribute (`!GetAtt MyInstance.PublicIp`,
    `!GetAtt MyALB.DNSName`).
  - `!Sub` — string substitution: `!Sub "arn:aws:s3:::${BucketName}/*"`.
  - `!Join`, `!FindInMap`, `!If`, `!ImportValue` (cross-stack).
- **Pseudo parameters:** `AWS::Region`, `AWS::AccountId`, `AWS::StackName`.
- **Stack operations:** create · update (**change sets** preview the diff) ·
  delete (removes all resources) · **drift detection** (finds manual changes) ·
  automatic **rollback** on failure.
- **`DependsOn`** to force ordering; **`DeletionPolicy: Retain`/`Snapshot`** to
  protect data (e.g. keep an RDS snapshot when the stack is deleted).
- **Nested stacks** and cross-stack **Export/ImportValue** for modular designs.

## Typical AWS Academy lab
Deploying infrastructure from a provided CloudFormation template, then
**updating** the stack (e.g. changing an instance type or adding a resource)
and observing the change set and rollback behaviour.

## High-yield gotchas (marks lost here)
- `!Ref` vs `!GetAtt` is the most commonly confused pair. `!Ref` on an EC2
  instance gives the **instance ID**; you need `!GetAtt Instance.PublicIp`
  for the address.
- YAML indentation errors fail the whole stack — **spaces only, never tabs**.
- AMI IDs are **Region-specific** → use `Mappings` (or an SSM parameter) rather
  than hardcoding, or the template breaks in another Region.
- A failed create rolls back and deletes everything by default — read the
  **Events** tab bottom-up to find the *first* failure, which is the real cause.
- Deleting a stack deletes its resources, including data stores, unless a
  `DeletionPolicy` says otherwise.

## Self-check questions
1. Which template section is mandatory?
2. `!Ref` or `!GetAtt` for: instance ID, ALB DNS name, a parameter value?
3. Stack creation failed — what's your diagnostic procedure?
4. How do you preview what an update will change before applying it?
5. How do you keep the database when the stack is torn down?

## My notes
_(fill in as we go)_
