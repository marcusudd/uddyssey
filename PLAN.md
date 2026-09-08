# Plan

Durable project state: backlog, decisions and open points. Session state
lives in `handoffs/` (gitignored, written by the handoff skill) — don't
put it here. Update this file when a decision lands or a backlog item
moves.

## Where things stand

The whole skill backlog (items 1–9) is grilled and built: tickets,
grill-me, in-loop, ship, greet + onboard + handoff, rubberduck,
research, goal, explain. The template ships a
`.gitignore` and install.sh merges it into the target repo (verified
against a temp repo). The testbed round ran 2026-09-01 (findings in
`report.md`, local working material) and led to the workflow redesign
below. Nothing is verified against the team's real Jira/GitHub yet —
see open points.

## Workflow redesign — decided and implemented 2026-09-01

Out of the testbed round (full spec and reasoning in `report.md`). PRs
are dropped entirely — a solo author can't approve their own PR, and the
gates move into ship instead:

- **Plans are files:** `plans/<YYYY-MM-DD>-<KEY>-<slug>.md`, committed
  with the branch's first commit. Written by rubberduck's Land (grill-me
  offers it standalone), worked by goal, closed by ship merge with a
  "Merged to main" line. The ticket keeps What & why / AC / Out of
  scope plus a pointer; the file owns the how. A re-grill writes a new
  dated file.
- **ship is start / push / merge** (PR and land modes gone). Merge runs
  only on the user's explicit ask, through four gates: local check
  green, branch CI green, the user's yes with diffstat + commit list on
  screen — before main changes at all — and a clean merge (conflicts
  are a hard stop). Regular merges,
  no squash — branch history stays reachable, old branches safe to
  delete.
- **goal ends at the pushed branch** — never merges.
- **CI triggers on every branch push** (replaces PR CI); the PR
  template is deleted.
- Rejected, so nobody relitigates: squash merges, fast-forward-only, a
  separate plan skill, dual plan sources (file + Jira), gitignored
  plans/. Branch protection and squash settings are moot without PRs.

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
   where the harness allows (Claude Code and Codex take it on the
   spawn call; Cursor has the knob but undocumented and unreliable —
   re-checked 2026-09-01, `research/subagent-model-selection.md`);
   dedupe against existing
   notes; never commits. Mentioned in AGENTS.md (context-saving
   rationale); offered from in-loop and rubberduck.
8. ~~goal~~ done (2026-08-31) — completion mode: a readied ticket
   (plan in Implementation notes) is driven to an opened PR without
   stopping for input. Ticket key required; no plan → rubberduck
   first. Loop: ship start → plan steps via in-loop delegation, check
   + local commit per step (red check → check's triage fork, routed
   without asking) → ship, whose gates (green check + confirmation on
   commits/PR draft) are the one planned stop. May change *how*, never
   *what* — a new decision or stuck debugging stops the run, always
   with a handoff. Never moves ticket status. Rejected:
   goal-to-tickets decomposition (different skill), start-as-consent
   for push/PR (ship's confirmation gate stays), landing the PR as
   exit (approval is human-paced). Mentioned in AGENTS.md workflow.

9. ~~explain~~ done (2026-09-08) — explains the assistant's last
   message (incl. a diff/traceback it showed) more simply, one step at
   a time, until the user says it landed; user-invoked or on explicit
   "didn't follow" signals, never proactive. Start level: developer in
   the stack who doesn't know this one thing. Opening turn: what it's
   about + plain-words version + the loop stated in the reply (keeps
   the plan in the transcript on every harness). Never "does that make
   sense?"; teach-back only after hard steps; "still don't get it" →
   which part, one level simpler, new words. Ends by re-asking the
   original question/choice in plain words. Mentioned in GUIDE.md only.
   Rejected: names simplify/eli5/clarify, ELI5 start level, asking for
   a level, `$ARGUMENTS` or any harness-specific frontmatter, a
   `.cursor/rules` alwaysApply rule against Cursor's skill fade,
   output styles as a substitute, other skills offering it. Research:
   `research/explain-skills-survey.md`,
   `research/progressive-explanation-pedagogy.md`,
   `research/explain-skill-harness-mechanics.md`.

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

## Live test round 2 — 2026-09-01, fresh target (uddyssey-livetest)

Fresh target repo `~/projects/uddyssey-livetest` (backend/frontend-
skelett, privat GitHub-repo marcusudd/uddyssey-livetest). Skills körda
på riktigt i barnsessioner (`claude -p` i targetet, verktygs-allowlist,
gate-svar via `--resume`). Verifierat grönt:

- install.sh: relativ path, kollisionsvarning (Cursors inbyggda
  goal/onboard), inventarie, gitignore-merge, plans/.gitkeep, inga
  skill-.gitkeeps.
- CI triggar på varje branch-push och blir grön (~22s) — inga PRs.
- check: gröna vägen lokalt + i CI; röda vägen rapporterar rått via
  subagent, fixar inget, erbjuder triage-forken.
- greet: triggar själv i färsk session, korrekt "ingen brief än"-
  frasering; senare session serverar handoff + flaggar briefen N
  commits bakom och erbjuder onboard.
- ship start utan .env: stannar korrekt, ingen branch, pekar på
  .env.example.
- ship push: check-gate, konventionell commit, **confirmation-gaten
  höll i icke-interaktiv körning** (git push var tillåtet — bara
  skillen hindrade); push först efter ja.
- ship merge: alla fyra gates i ordning; **nej lämnade main orörd**;
  ja → `--no-ff`, "Merged to main"-rad i planfilens header, commit på
  main, push. Ticketstatus orörd, branchen lämnad åt användaren.
- handoff: rätt filnamn/plats, gitignorerad, referenstät.

**Fynd — onboard kan inte skriva sin brief i Claude Code:**
`.git/onboard.md` stoppas av harnessens sensitive-file-skydd (både
Write-verktyget och shell-redirect, även med Write tillåtet).
Barnsessionen skrev till /private/tmp och bad användaren flytta filen.
Placeringen "inuti .git så den aldrig kan committas" kolliderar alltså
med harnessen — behöver en grill-runda (t.ex. gitignorerad fil i
repo-roten i stil med handoffs/). Onboards delta-läge stupar på samma
skrivning.

Kvar från rundan: Jira-legen (tickets/rubberduck/goal end-to-end —
.env-kopiering till targetet blockerades av harness-klassificeraren,
Marcus kopierar själv), Codex/Cursor (inga CLI:er på maskinen —
manuellt), onboard --refresh (meningslös tills skrivfyndet är löst).

## Open points — verification against real services

- **tickets not verified live:** the first run against the team's Jira
  has to confirm the Story issue type, the project key and the Blocks
  link type name. `.env` must be filled in first.
- ~~**ship not verified live**~~ — push and merge modes verified
  2026-09-01 against uddyssey-livetest (see live test round 2); the
  group repo's own CI remains unexercised.
- **install.sh deletes nothing:** if the template was installed before,
  `.github/ISSUE_TEMPLATE/` stays in the group repo and has to be
  removed by hand.
- **rubberduck/research/goal not verified live:** need a filled `.env`
  in the livetest target (greet/handoff verified, onboard blocked on
  the .git write finding — see live test round 2).
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
  New 2026-09-01: **Cursor ships built-in skills named `goal` and
  `onboard`** (`~/.cursor/skills-cursor/`, seen on Marcus's machine) —
  direct name clashes with two of ours. install.sh's warning only looks
  at `~/.claude/skills`, so it stays silent about this.

## Open points — internal audit 2026-08-31

Four subagents reviewed the whole set (skill consistency, install/setup,
portability + concurrency, newcomer walkthrough). No broken pointers, no
routing gaps, no description overlaps that misfire. Found, unfixed:

- ~~**Codex/Cursor are asserted, not wired.**~~ Settled on paper
  2026-09-01 — see "Harness discovery" below. Nothing needs wiring; what
  remains is running it live.
- **Ticket status is stated inconsistently:** ship and goal both say
  "never moves ticket status", but tickets' Reconcile closes tickets
  via transitions. True but confusing — worth one clarifying clause.
- **grill-me forces English in chat** (`skills/grill-me/SKILL.md:47`,
  the closing summary) against every sibling's "chat in the user's
  language".
- **goal's early stop strands work:** it commits only locally, so a
  stop before ship leaves no pushed branch, no PR and no Jira trace —
  only a gitignored handoff on one machine. Person B sees nothing.
- **Re-install never deletes.** `cp -R template/.` only adds and
  overwrites; a file removed from the template survives in the target
  (the `.github/ISSUE_TEMPLATE/` point above is one instance of this).
- **Portability is confined but real:** `check.sh` hardcodes
  uv/ruff/mypy/npm, ship hardcodes `gh` and `main`. All fail loudly,
  but a second project means editing `skills/`.
- **`ship start` doesn't check for an existing branch** on the key —
  two people can start the same ticket; it surfaces late.
- ~~PR template says `closes #NN`~~ — template deleted with the
  redesign.
- Prerequisites (`gh auth login`, uv, Node 22, `.env`, running onboard
  once per clone) were undocumented — now covered by `template/GUIDE.md`.

## Open points — testbed findings 2026-09-01 (report.md, still unfixed)

`report.md` is local working material (untracked), so the open items
live here:

- **mypy's version floats** in check.sh (`uv run --with mypy`) — CI can
  go red with no code change. Pin it as a dev dependency like ruff.
- **greet/onboard staleness check assumes linear history** — a diverged
  sha reads as "N commits behind"; use `git merge-base --is-ancestor`.
- **Skills vanish on branches cut from an older base** — nothing warns,
  and the agent's skill listing can lag the filesystem both ways.
- **ship start has no answer for a diverged main** — `git pull` is
  assumed to succeed cleanly.
- **grill format inflates scope** — questions become recommendations
  become AC; no step compares the result against the original ticket.
  Partly mitigated by plan files being reviewable; the delta-line fix
  options in report.md are not implemented.
- **Ticket granularity** — user stories vs sub-tickets. The user wants
  this grilled, not decided by an agent. Do not create tickets for it.

## Open point — research skill leaks into the main session

Seen live 2026-09-01: delegation worked, but the main session gathered
raw material around it anyway — a `strings` dump of the Codex binary
before spawning (largest single context cost of the session, and it
produced a *wrong* conclusion that had to be retracted), plus its own
WebFetch calls to double-check the agent. The skill says what the agent
must do and nothing about what the main session must not do.

Proposed (not built, needs a grill pass): main session never gathers
itself — no fetch/curl/strings/greps into external installs, before or
after spawn; agent quotes raw source text for the load-bearing claim
rather than a summariser's paraphrase; a finding that contradicts
"Decisions in force" gets a second agent, not a main-session check.

## Harness discovery — settled 2026-09-01

Researched against vendor docs and the `openai/codex` source; notes in
`research/codex-skills-and-instructions.md`,
`research/cursor-skills-and-instructions.md`,
`research/cross-harness-skill-conventions.md`.

**The two-folder design is correct and minimal.** `SKILL.md` with
`name` + `description` frontmatter is an open standard (agentskills.io,
originally Anthropic's) that all three harnesses implement. Only the
directory differs:

- Codex reads `.agents/skills/` — its primary documented path, walked
  from cwd up to the repo root, then `~/.agents/skills`. Also reads
  `.codex/skills/`.
- Cursor reads `.agents/skills/` and `.cursor/skills/`, plus
  `.claude/skills/` and `.codex/skills/` for compatibility.
- Claude Code reads **only** `.claude/skills/` — never `.agents/`.

So Claude Code forces the second copy; nothing can collapse it to one
folder. `AGENTS.md` is read automatically by both Codex (git root down
to cwd, closer files win, 32 KiB cap via `project_doc_max_bytes` —
ours is 5.8 KB) and Cursor (root + nested). All 11 skills use only
`name` + `description`, which is inside the six spec-portable fields.
Nothing to configure in `template/` for either tool.

Still to check live (test-repo round):

- **Cursor scans both our folders** (`.agents/skills/` and
  `.claude/skills/`), so every skill is present twice. Whether it
  dedupes by name or loads both is unconfirmed — one weak source says
  it dedupes by path, which would mean doubles.
- Skills actually firing on description match in Codex and Cursor.
- Whether Cursor's built-in `goal`/`onboard` shadow ours.
- Codex's precedence when a name exists in both `.codex/skills/` and
  `.agents/skills/` — not documented anywhere we could find.
- Cursor drops a `/name`-invoked skill after one message ("fades" —
  `research/explain-skill-harness-mechanics.md`). explain's multi-turn
  loop relies on the agent restating the loop in its reply; check that
  holds in Cursor, and that Option+Enter (Custom Mode) is the fallback.
  Codex keeps injected skill text in history (verified in source).

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
- **Research notes stay local** (decided 2026-09-01): `research/` is
  gitignored and untracked — working material, never pushed. The old
  notes remain in the public remote's history; only a history rewrite
  would purge them.
- **After a red check** (decided 2026-08-28): triage fork, stated in
  check's Boundary section — small fix with known cause → fix inline in
  the active mode; unknown cause → in-loop (which carries the debugging
  discipline: red repro before fix, regression test recommended); new or
  bigger work → tickets. Exit gate: the fix is done only when the same
  check reruns green. Rejected: a dedicated diagnose skill (shadowing
  confirmed live, overlaps parked triage); a hard regression-test
  requirement (PR review settles it); routing text in consumers or
  AGENTS.md (one home in check).
