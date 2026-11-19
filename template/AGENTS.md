# How we work in this repo

Read this before making changes. Applies to humans and AI agents alike.

New here? `GUIDE.md` is the friendlier map — setup per tool, the workflow
end to end, and what each skill does. This file is the rulebook it points
back to.

## Session start

Agents: at session start, use the greet skill before anything else — it
reads the onboard brief and the latest handoff and tells you where things
stand. When the session is winding down, offer the handoff skill.

This repo's skills live in `.claude/skills/` (`.agents/skills/` for Codex
and Cursor). If a personally installed skill shares a name with one of
them, the repo's copy governs — read it from that path instead.

## Project settings

Project-specific rules and settings live in `AGENTS.project.md` in the
repo root — read it right after this file. The installer never creates
or overwrites it, so what's written there survives a reinstall. Where
it conflicts with this file, it wins for this project.

One setting the skills read from it:

- `Ticket source: jira` — the default, also when the file or the line
  is missing.
- `Ticket source: none` — ticketless mode, below.

## Ticketless mode

For solo projects without Jira. The workflow below stays the same —
grill, plan file, branch, check after each step, ship's gates — minus
the ticket:

- No Jira calls and no tickets skill. Work starts with a grill
  (grill-me) or a rubberduck on a loose description and lands as a
  plan file.
- Plan files: `plans/<YYYY-MM-DD>-<slug>.md`, header `Ticket: none`.
  The slug stands in for the ticket key everywhere a skill asks for one.
- Branches: `feature/<slug>` or `fix/<slug>`.
- Work discovered along the way becomes a new plan file, not a ticket.

## Workflow: ticket → plan → branch → main

1. Every change starts with a Jira ticket in the backlog (agents: the
   tickets skill drafts and creates them — it needs Jira credentials,
   see `.env.example`).
2. Ticket not fully thought through? Optional: rubberduck it first — the
   rubberduck skill researches the codebase, settles the open decisions
   with you and lands them as a dated plan file in `plans/` before any
   branch is cut. The ticket keeps the what and why; the plan file owns
   the how. Plan files are committed (with the branch's first commit)
   and stay as history — a re-grill writes a new dated file.
3. Branch off main, named after the ticket's Jira key. The key must be in
   the branch name and uppercase — that is how Jira links commits
   to the ticket: `feature/PROJ-123-short-description` or
   `fix/PROJ-123-short-description` (e.g. `feature/PROJ-123-login-endpoint`).
   (Agents: the ship skill's start mode creates the branch.)
4. Work the plan. Agents commit to the branch automatically after each
   green check (`/check` if you use an agent, otherwise
   `bash .agents/skills/check/check.sh` — CI runs the same script on
   every branch push). Pushes to the branch are proposed — when a plan
   step or the plan is done — and always check-gated.
5. Merging to main happens only through the ship skill's merge mode,
   only when you explicitly ask for it, and only through its gate:
   local check green, branch CI green, your yes with the diff in front
   of you — before main changes at all — and a clean merge (any
   conflict stops the run). Merges
   are regular merges — no squash, so branch history stays reachable
   from main and old branches are always safe to delete. Never push to
   main by hand. No PRs — CI on every branch push replaces them.

In ticketless mode, steps 1 and 3 change as described above.

Once a ticket's plan file exists, agents can run steps 3–4 in one go:
the goal skill branches, works the plan with a check and a commit after
each step, then pushes the branch through ship's normal gates —
stopping only when a real decision comes up. Merging to main stays
yours, always.

Stopping mid-ticket? Agents: the handoff skill saves the session state to
`handoffs/` (gitignored) so the next session can resume where you left off.

Hit a question the codebase can't answer — library behavior, API facts,
what a spec says? Agents: the research skill sends a background agent to
primary sources and saves the answer as a note in `research/`, keeping
your main session's context lean.

## Commits

- One logical change per commit
- Conventional commits: `<type>: <subject>` where type is one of `feat`,
  `fix`, `docs`, `refactor`, `test`, `chore`. A scope (`feat(auth): ...`)
  is allowed, never required.
- Subject: imperative mood, lowercase after the colon, hard limit 72
  chars, no period, no emojis
- No Jira key in the subject — the branch name carries the ticket link
- Body only when the why isn't obvious from the diff
- No AI attribution (`Co-Authored-By: Claude`, "Generated with", etc.)
- Never `--no-verify`, never force-push shared branches

## Gotchas

A trap that cost real time goes into `docs/gotcha/<category>.md`, in the
same commit as the fix — what happened, not only what to do. One file
per category, lowercase ASCII names; add a file when none fits. Read the
folder before you start on an area you haven't touched, and when
something fails without an obvious cause. The conventions are in
`docs/gotcha/README.md`.

## Project structure

The repo is `backend/` + `frontend/`. New files go where the trees below
say — when you're unsure where something belongs, this section decides,
not taste.

Backend (FastAPI):

```
backend/
├── alembic.ini
├── alembic/versions/    # migrations — never edit applied ones
├── app/
│   ├── main.py          # creates the app, include_router
│   ├── api/
│   │   ├── deps.py      # shared dependencies (get_db, current user)
│   │   └── routes/      # one file per resource: users.py, auth.py
│   ├── core/            # config.py (pydantic-settings), db.py (engine +
│   │                    # sessionmaker), security.py
│   ├── models/          # SQLAlchemy models, one file per resource
│   ├── schemas/         # Pydantic request/response, one file per resource
│   └── services/        # business logic — never imports fastapi
└── tests/               # mirrors app/: tests/services/test_auth.py
```

Import direction: `api/routes → services → models + core/db`, never the
other way. Schemas may be imported by both routes and services.

Frontend (React + Vite):

```
frontend/src/
├── main.jsx             # entry
├── App.jsx              # router + providers
├── index.css            # Tailwind entry point
├── api/                 # client.js + one file per resource (users.js)
├── components/          # shared components (UserCard.jsx)
├── hooks/               # useAuth.js
├── pages/               # one file per route (LoginPage.jsx)
├── utils/               # helpers (formatDate.js)
└── assets/
```

Folders are by type, not by feature. When one view grows past ~5 related
files, move it to `src/features/<name>/{api,components,hooks}` — and from
that day on: no imports between features. No barrel files (index.js that
only re-exports).

## Code style

Backend (FastAPI / Python):
- async/await throughout — no blocking calls inside async functions
- Type hints on all signatures; `X | None`, `list[str]` — modern syntax
- Services never import from `fastapi`; routers convert exceptions to
  `HTTPException`
- Ruff is the source of truth for formatting (line length 88)

Frontend (React / Tailwind):
- Function components only, one component per file, hooks at the top
- Tailwind utility classes inline — no CSS modules or styled-components
- API calls in `api/` files, not inline in components
- No `console.log` in committed code

## Never

- Never commit `.env`, credentials, `*.pem` or anything secret
- Never skip or disable a test to make CI pass — fix it or delete it
  deliberately
- Never edit applied migration files — create a new migration
