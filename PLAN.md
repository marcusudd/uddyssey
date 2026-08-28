# Plan

Durable project state: backlog, decisions and open points. Session state
lives in `handoffs/` (gitignored, written by the handoff skill) — don't
put it here. Update this file when a decision lands or a backlog item
moves.

## Where things stand

All skills through backlog item 7 are grilled and built: tickets,
grill-me, in-loop, ship, greet + onboard + handoff, rubberduck,
research. The template ships a
`.gitignore` and install.sh merges it into the target repo (verified
against a temp repo). Nothing is verified against the team's real
Jira/GitHub yet — see open points.

## Skill backlog (one grill session per skill, in order)

1. ~~tickets~~ done
2. ~~grill-me~~ done
3. ~~in-loop~~ done
4. ~~ship~~ done
5. ~~greet + onboard + handoff~~ done (2026-08-28, one shared grill
   session)
6. ~~rubberduck~~ done (2026-08-28) — ticket-to-ready: read ticket →
   in-loop research → grill → land in the ticket via the tickets
   reconcile gate. No goal artifact files; Jira stays the single source.
7. ~~research~~ done (2026-08-28) — external questions only (codebase
   research stays in in-loop/rubberduck); background agent against
   primary sources → `research/<kebab-topic>.md`, answer first, source
   URL per claim, no frontmatter; cheaper mid-tier model per spawn
   where the harness allows (Claude Code and Codex do, Cursor doesn't —
   see `research/subagent-model-selection.md`); dedupe against existing
   notes; never commits. Mentioned in AGENTS.md (context-saving
   rationale); offered from in-loop and rubberduck.
8. goal — not yet grilled.

Later pile: endpoint, component, triage, import-linter/eslint enforcement
of the structure, epic grouping of a plan's tickets, status transitions
in ship (REST transitions — smart commits ruled out), shared platform
file step 2 if more platforms become relevant, branch deletion in land.

## Plan forward

Per skill: one grill session (frontier empty + user confirms) → build →
sync → commit → handoff. When the whole backlog is built: **test every
skill in a test repo** (run `install.sh` against a fresh repo with a
backend/ + frontend/ skeleton, run each skill for real — tickets and
ship need a filled `.env` and `gh` against the team's environment)
before installing into the group repo.

## Open points — verification against real services

- **tickets not verified live:** the first run against the team's Jira
  has to confirm the Story issue type, the project key and the Blocks
  link type name. `.env` must be filled in first.
- **ship not verified live:** also needs `gh` logged in against the
  group repo; land mode assumes the branch protection/approval flow.
- **install.sh deletes nothing:** if the template was installed before,
  `.github/ISSUE_TEMPLATE/` stays in the group repo and has to be
  removed by hand.
- **greet/onboard/handoff/rubberduck/research not verified live:**
  covered by the test repo step above (rubberduck also needs a filled
  `.env`).
- Cosmetic: install.sh's `.gitignore` merge drops the blank lines
  between groups.
- **Skill name collisions:** confirmed live 2026-08-28 in the testbed —
  a personal `~/.claude/skills/onboard` shadowed the repo's completely
  (the repo's onboard never appeared in the session's skill list; same
  for grill-me). Fixed two ways: install.sh warns when ~/.claude/skills
  shares names with skills/, and AGENTS.md states the repo's copy
  governs on a name clash. Prefixed names (uddyssey-grill-me) were
  considered and rejected — a prefix only fixes /name invocation, not
  description-based triggering, and two live variants would still
  confuse. Remaining: shadowing behavior on Codex/Cursor unverified.

## Decisions in force (don't change without asking)

- Rules and skills stay general — usable in other projects without
  editing. If a skill needs project-specific info, the answer is a setup
  step run with install.sh — and only if the need actually exists (so
  far it doesn't; `.env` for Jira is the one exception). The repo should
  stay simple and easy to explain.
- Everything lives in the skill folders — no scripts or config files in
  the group repo's backend//frontend/, no manual one-off steps (that's
  what killed mypy.ini and eslint). `.env.example` in the root is an
  explicit exception.
- No symlinks; two generated folders; checked into the group repo; one
  source + sync. Stack locked to FastAPI + React. Prescriptive beats
  flexible.
- Jira is the ticket source; GitHub issues are not used. The whole Jira
  API surface lives in `skills/ticket-platform/PLATFORM.md` — skills
  point there; switching platforms means rewriting one file.
- **Group repo:** conventional commits (see AGENTS.md). **This repo:**
  imperative subjects, no prefixes, no AI attribution. Don't mix them up.
- CI assumes a `backend/` + `frontend/` layout.
- Session state goes through the handoff skill into `handoffs/`; this
  file is the durable home for backlog and decisions (decided
  2026-08-28 — replaced the old untracked `HANDOFF.md`).
- **After a red check** (decided 2026-08-28): triage fork, stated in
  check's Boundary section — small fix with known cause → fix inline in
  the active mode; unknown cause → in-loop (which carries the debugging
  discipline: red repro before fix, regression test recommended); new or
  bigger work → tickets. Exit gate: the fix is done only when the same
  check reruns green. Rejected: a dedicated diagnose skill (shadowing
  confirmed live, overlaps parked triage); a hard regression-test
  requirement (PR review settles it); routing text in consumers or
  AGENTS.md (one home in check).
