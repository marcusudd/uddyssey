---
name: ship
description: Take a ticket from branch to merged work on main — start the branch, push work, or merge into main through the safety gate. Use when someone wants to start on a ticket, push, or merge finished work — offer it when work on a ticket seems done.
---

# ship

The delivery wrapper around the workflow in AGENTS.md: ticket → branch →
main. Three modes, one skill — they share the gates below. Every mode
needs a ticket key; without a ticket, stop and offer the tickets skill
instead. Platform calls (ticket fetch, key rules):
`../ticket-platform/PLATFORM.md`.

In ticketless mode (`Ticket source: none` in `AGENTS.project.md`, see AGENTS.md)
there is no ticket and no platform call: every mode needs a plan file in
`plans/` instead, and its slug stands in for the key.

Offering ship — when work on a ticket branch seems done — is a
question; the user can decline.

## Gates

- **Check gate** — before anything is pushed or merged, run the check
  skill and stop on failure: report, don't fix. Only the user's explicit
  "push anyway" overrides a red check.
- **Confirmation gate** — show what is about to leave the machine
  (commit messages; in merge mode the diffstat, the commit list and the
  word "main") and wait for a yes given at that moment — a standing
  "always do it" never counts. Committing locally is fine before the
  gate; push and merge happen only after it.

## start — begin work on a ticket

1. Fetch the ticket (platform file) and show its summary. Ticketless:
   show the plan file's header and Steps instead.
2. `git switch main && git pull`, then branch off:
   `feature/<KEY>-short-slug`, or `fix/` when the ticket is clearly a
   bug fix. The key stays uppercase — that is what links the branch and
   its commits to the ticket. Ticketless: `feature/<slug>` from the
   plan file's name.

If the ticket has a plan file in `plans/` that is not yet committed,
the branch's first commit includes it.

## push — push the current branch

1. Check gate.
2. Commit the uncommitted work, following the commit rules in
   AGENTS.md (conventional commits). Propose a split into logical
   commits when the diff is clearly several changes; otherwise one
   commit. No ticket key in subjects — the branch name carries the
   link.
3. Confirmation gate, then push the current branch to origin.

Recommend a push when something is achieved — a plan step done, a plan
completed — never push unasked.

## merge — take the branch into main

Entered only when the user explicitly asks for it — never offered as a
default next step, never run from goal. Four gates, in order, no
exceptions — and the user's yes comes before main changes at all:

1. Check gate on the branch.
2. The branch is pushed and its latest CI run is green — verify
   remotely (`gh run list --branch <branch>` or the API). No CI signal,
   or a red run → stop and report.
3. `git switch main && git pull`, then the confirmation gate, while
   main is still untouched: show the diffstat
   (`git diff --stat main...<branch>`), the commit list
   (`git log --oneline main..<branch>`) and the word "main", and wait.
   Only the user's yes, given at that moment, unlocks the rest — a no
   leaves main exactly as it was.
4. `git merge --no-ff <branch>`. The merge must be clean: any conflict
   is a hard stop — abort with `git merge --abort`, report, and never
   resolve conflicts yourself.
5. Write the outcome line into the ticket's plan file header
   ("Merged to main YYYY-MM-DD"), commit it on main, then
   `git push origin main`.

Merges are regular merges (no squash, no rebase): every branch commit
stays reachable from main, so old branches are always safe to delete —
that housekeeping is the user's own. `git log --first-parent main`
gives the one-line-per-plan view.

## Boundary

Ship ends when the push or merge result is reported. It never merges
without the four gates, never resolves conflicts, never force-pushes,
and never moves ticket status — the team moves cards on the board.
