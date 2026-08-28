---
name: greet
description: Session-start orientation — read the onboard brief, the latest handoff and git status, then greet with a short state summary. Use at the start of every session before anything else; AGENTS.md's session-start instruction points here.
---

# greet

Orients a session at near-zero cost. Read exactly three things, nothing
else:

1. The brief: `$(git rev-parse --git-common-dir)/onboard.md`
2. The latest handoff: the last file, sorted, in
   `$(git rev-parse --show-toplevel)/handoffs/`
3. `git status -sb`

Then greet in the user's language: 3–4 lines — current task and branch
from the handoff, notable git state — ending with "what are we working
on?".

## Flag, don't fix

- No brief → say so and offer the onboard skill. Never run it on your
  own.
- The brief's sha is behind HEAD → mention how far and offer onboard.
- No handoff → fresh start; say so.
- Missing input is reported, never reconstructed — no exploring the
  codebase to fill gaps.
