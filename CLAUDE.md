# Context for Claude (read this first, every session)

This repo is the study record for **tanbl123's AWS Academy Cloud Architecting
(ACAv3) practical test**, covering **Modules 1–10**. The container is wiped
between sessions, so this repo is the only memory of what we have already done.

## At the start of every session
1. Read `PROGRESS.md` — it holds current status, the next step, and weak areas.
2. Read `notes/mistakes-log.md` — do not re-teach what is already solid; do
   re-drill what is listed there.
3. Pick up from the "Next step" line in `PROGRESS.md`. Do not restart from
   Module 1 unless asked.

## At the end of every session (or after any meaningful chunk of work)
1. Update the status table and "Next step" in `PROGRESS.md`.
2. Append a dated entry to the session log in `PROGRESS.md`.
3. Add any new misconception or wrong answer to `notes/mistakes-log.md`.
4. Add anything learned about the real lab/test format to the relevant
   `modules/*.md` file.
5. Commit and push to `claude/cloud-computing-practice-8s3q0y`.

## How the user wants to work (agreed 2026-09-04)
- They do the AWS Academy labs themselves; Claude guides and explains.
- Do not build replacement labs unless asked.
- An offline AWS CLI sandbox exists (see README) for rehearsing commands
  without spending AWS Academy lab hours.

### Phase order — IMPORTANT
1. **Phase 1 (current): cover Modules 1-10.** Teaching, guiding and explaining
   only. **Do NOT generate practice questions, quizzes or drills during this
   phase**, and do not push the user to be tested. If a gap shows up while
   explaining, note it in `notes/mistakes-log.md` and keep going.
2. **Phase 2 (after all of Modules 1-10 are covered): practice questions.**
   The user will explicitly ask for questions, answer them, and Claude marks
   them. Only start this when the user asks.

### Coding is NOT tested (confirmed by lecturer, 2026-09-08)
The practical test is **console build tasks only**. The lecturer confirmed there
is **no coding component**. So whenever a task involves code — AWS CLI commands,
CloudFormation YAML, Lambda handler code, SQL, JSON policy documents — **just
give the user the complete, correct code**. Do not make them write it, and do
not turn it into a practice exercise. Spend their time on the console skills
that are actually graded.

(Practice questions in Phase 2 should therefore be **console-based scenarios**,
not code-writing tasks.)

### Out-of-scope modules — still REQUIRED for coursework marks
The practical test covers Modules 1-10 only, but **coursework marks require every
guided lab in every module to be submitted, deadline 8 September 2026 midnight.**
So Modules 11-17 are out of *test* scope but NOT optional. Help fully with them;
just keep them out of the practical-test progress table and record them in
`notes/beyond-module-10.md`.

## Where to record
Work on and push to **`main`** (the user granted this explicitly on
2026-09-04). The branch `claude/cloud-computing-practice-8s3q0y` was the
original working branch and is kept in sync, but `main` is the source of truth.

## Module numbering — CONFIRMED, do not re-derive
The real course has **17 modules + Capstone**, confirmed from Canvas on
2026-09-04 and recorded in `modules/00-overview.md`. It is NOT the standard
ACAv3 layout. In particular: **Module 3 = Securing Access**, **Module 7 = VPC**,
**Module 8 = Connecting Networks**, **Module 9 = Securing User, Application and
Data Access**, **Module 10 = Monitoring, Elasticity and HA**.
**CloudFormation is Module 11 and DR/RTO/RPO is Module 16 — both OUT of the
test scope.** Trust `modules/00-overview.md` over any general knowledge of ACAv3.

Exact lab titles and the lecturer's emphasis should still be corrected in these
files as the user confirms them.
