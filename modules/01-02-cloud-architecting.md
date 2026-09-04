# Modules 1–2 — Course Intro & Introducing Cloud Architecting

**Status:** not started | **Confidence:** –

## Scope
Foundations and vocabulary. Rarely a hands-on task on its own, but the
*reasoning* here is what justifies your design choices in later modules.

## Key concepts to know cold
- **AWS Well-Architected Framework — 6 pillars:** Operational Excellence,
  Security, Reliability, Performance Efficiency, Cost Optimization,
  Sustainability.
- **Shared Responsibility Model:** AWS = security **of** the cloud
  (hardware, global infra, managed service internals). Customer = security
  **in** the cloud (data, IAM, OS patching on EC2, security groups, encryption).
- **Global infrastructure:** Region → Availability Zone (one or more discrete
  data centres) → Edge location (CloudFront/Route 53). AZs in a Region are
  connected by low-latency links.
- **Design principles:** design for failure, decouple components, implement
  elasticity, think parallel, don't fear constraints.
- **Cost model:** pay-as-you-go, pay less when you reserve, pay less per unit
  as you use more, CapEx → OpEx.

## High-yield gotchas
- Multi-AZ = **high availability** within one Region. Multi-Region = **disaster
  recovery / global reach**. Do not mix these up.
- "Highly available" ≠ "fault tolerant" ≠ "scalable". HA = minimal downtime;
  fault tolerant = no interruption on component failure; scalable = handles
  load growth.
- Patching an EC2 guest OS is **your** job; patching RDS is **AWS's** job.

## Self-check questions
1. Name the 6 pillars without looking.
2. An exam scenario says "must survive the loss of a single data centre".
   What does that translate to architecturally?
3. Who patches the OS on EC2? On RDS? On Lambda?

## My notes
_(fill in as we go)_
