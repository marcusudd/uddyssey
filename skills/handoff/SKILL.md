---
name: handoff
description: Write a dated handoff capturing where the session stands — task, branch, progress, exact stopping point — so the next session resumes without re-discovery. Use when someone asks for a handoff, or offer it when the session sounds like it is ending; never write one unprompted.
---

# handoff

Captures session state for the next session. The reader is an agent (the
greet skill serves it at session start), so keep it factual and
reference-dense — `file:line` over prose. Written in English.

## Placement

Always `$(git rev-parse --show-toplevel)/handoffs/` — resolve the repo
root, never write relative to the current directory. Create the folder if
it doesn't exist. It is gitignored on purpose: handoffs are personal
continuity notes; anything the team needs lives in Jira or the repo
(the ticket, the plan file, the branch).

Filename `YYYY-MM-DD-handoff-N.md` — today's date, N from 1, incremented
if the name is taken. Sorted order is chronological; the newest handoff is
the last file.

## Trigger discipline

An explicit ask is its own confirmation — write it. When you only infer
that the session is ending ("continuing tomorrow", "I have to go"), offer
a handoff and wait for a yes.

## Gather

From the session and `git status -sb`: the ticket and branch, what got
done, the exact stopping point, what remains, files touched with
tested/untested status, and the decisions or gotchas the next session must
not rediscover. Absolute dates, never "today".

## Template

```markdown
---
date: [ISO timestamp]
---

# Handoff: [short description]

## Task

- Ticket: [PROJ-123, or "no ticket — in-loop"]
- Branch: [branch name]

## State

Done:

- [x] [completed work, with file:line refs]

In progress:

- [ ] [item and exact stopping point]

Remaining:

- [ ] [next item]

## Files touched

- `path/to/file` — [modified; tested / untested]

## Next steps

1. [immediate next action]

## Gotchas

[decisions, blockers, assumptions — absolute dates]
```

## Done

Reply with the saved path and the first next step.
