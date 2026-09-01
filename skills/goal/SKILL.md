---
name: goal
description: Drive a readied ticket's plan to a pushed branch in one run — branch, work the plan file's steps, check and commit after each, then push through ship's gates. Use when someone wants a ticket run to completion or asks for goal; the plan file must already exist in plans/.
---

# goal

The completion mode: once a ticket has a plan file in `plans/`
(usually from rubberduck), goal owns finishing it — branch to pushed
branch without stopping for input. It stops for decisions, never for
reassurance.

Needs a ticket key. Without one, stop: a loose goal goes through
tickets (and grill-me) first — goal is not a way around the workflow.
Find the ticket's plan file in `plans/` — files are named
`<YYYY-MM-DD>-<KEY>-<slug>.md`; the latest date for the key wins. The
plan file is the only source goal reads the plan from — never the
ticket's description. No plan file → offer rubberduck
(`../rubberduck/SKILL.md`) and take over once the plan has landed.

## The loop

1. **Start** — ship's start mode (`../ship/SKILL.md`): branch off main,
   named with the ticket key. Commit the plan file first if it is
   uncommitted.
2. **Work the plan's Steps, one by one** — delegate as in in-loop's
   Delegation section (`../in-loop/SKILL.md`). After each step, run
   check (`../check/SKILL.md`); when green, commit locally (commit
   rules in AGENTS.md). Red check → the fork in check's Boundary,
   routed without asking: cause known → fix inline; cause unknown →
   in-loop's Debugging discipline (red repro before fix). Either way
   the step is done only when the same check reruns green. Debugging
   stuck after honest attempts → stop.
3. **Push** — ship's push mode. Its gates stand: the check gate, and
   the confirmation gate on the commits is goal's one planned stop.
   Report the pushed branch and any deviations from the plan.

Goal ends at the pushed branch. Merging to main is never goal's move —
that is ship's merge mode, entered only when the user asks for it.

## Deviations

Plans rarely survive contact with the code. Goal may change the *how*,
never the *what*: a step already done, a file named differently, a
step that needs splitting — adapt, continue, note it in the final
report. Anything that needs a new decision — a different approach than
the plan's, work outside the ticket, a plan assumption that turns out
wrong — stop.

## Stopping

Every stop that isn't the exit writes a handoff
(`../handoff/SKILL.md`): exact state plus what blocks. Never a dead
session.

## Boundary

- Never bypass ship's gates — nothing is pushed without a green check
  and the user's yes on the commits.
- Never merge to main.
- Never touch ticket status — the team moves the cards.
- Never widen scope — new work discovered goes to tickets, not into
  the branch.
