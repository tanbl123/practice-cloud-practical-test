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

### Out-of-scope modules
The practical test covers Modules 1-10 only, but the user may ask for help with
**later modules (11, 12, 13, ...)** for normal coursework. Help fully with
those — just keep them out of the practical-test progress table and record them
in `notes/beyond-module-10.md` so test prep stays clearly separated.

## Where to record
Work on and push to **`main`** (the user granted this explicitly on
2026-09-04). The branch `claude/cloud-computing-practice-8s3q0y` was the
original working branch and is kept in sync, but `main` is the source of truth.

## Accuracy note
Module scope below is written from the standard ACAv3 syllabus. Exact lab
titles and the lecturer's emphasis should be corrected in these files as the
user confirms them.
