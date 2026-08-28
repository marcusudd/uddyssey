---
name: onboard
description: Scan the codebase and write a compact "what is built" brief that sessions load as context, with cheap delta updates on later runs. Use when someone asks to onboard, or after greet reports the brief missing or stale.
---

# onboard

AGENTS.md prescribes how the repo should look; the brief this skill writes
records what actually exists. The brief is agent context — greet loads it
at session start and serves the human-facing overview.

## Placement

`$(git rev-parse --git-common-dir)/onboard.md` — inside the git directory,
so it can never be committed, needs no gitignore entry, and is shared
across worktrees. Not a git repo → onboard needs git; say so and stop.

## Modes

If the brief exists, read its frontmatter first.

- No brief, or the user passed `--refresh`: full scan.
- Stored sha equals HEAD: report that the brief is current and load it.
  Done.
- Stored sha differs: delta update — `git diff --name-status <sha> HEAD`,
  read only added and modified files, fold them in, drop references to
  deleted files, update the frontmatter. Leave unaffected sections alone.

## Scan

Delegate the reading to an explorer-style subagent and write the brief
from its report — the main context gets the brief, not the raw files. (On
a harness without subagents: read narrowly yourself.)

Read: README, AGENTS.md, manifests and configs (pyproject.toml,
package.json, alembic, CI), entry points, the migrations list, and a
representative sample per folder in AGENTS.md's structure trees. Skip
lock files, generated folders (node_modules, .venv, dist, __pycache__)
and binary assets.

## The brief

Target under ~80 lines — it is read every session, so cheap beats
complete. Frontmatter: `sha`, `branch`, `date`. Sections:

- What this is — one paragraph, from the README
- Backend — the routes, services, models and migrations that exist
- Frontend — the pages, components and hooks that exist
- Deviations — code that breaks AGENTS.md's structure or rules. Flag
  here, never fix.

Summarize patterns ("CRUD routes for users and projects, all async"),
don't inventory every file. When done, show the brief and say which sha
and branch it was written from.
