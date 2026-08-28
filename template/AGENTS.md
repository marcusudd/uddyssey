# How we work in this repo

Read this before making changes. Applies to humans and AI agents alike.

## Session start

Agents: at session start, use the greet skill before anything else — it
reads the onboard brief and the latest handoff and tells you where things
stand. When the session is winding down, offer the handoff skill.

## Workflow: ticket → branch → PR

1. Every change starts with a Jira ticket in the backlog (agents: the
   tickets skill drafts and creates them — it needs Jira credentials,
   see `.env.example`).
2. Ticket not fully thought through? Optional: rubberduck it first — the
   rubberduck skill researches the codebase, settles the open decisions
   with you and lands them in the ticket before any branch is cut.
3. Branch off main, named after the ticket's Jira key. The key must be in
   the branch name and uppercase — that is how Jira links commits and PRs
   to the ticket: `feature/PROJ-123-short-description` or
   `fix/PROJ-123-short-description` (e.g. `feature/PROJ-123-login-endpoint`).
   (Agents: the ship skill's start mode creates the branch.)
4. Before pushing: run the checks locally (`/check` if you use an agent,
   otherwise `bash .agents/skills/check/check.sh`). CI runs the same script.
5. Open a PR against main. CI must be green and one teammate must approve
   before merge; merges are squash merges. Never push directly to main.
   (Agents: the ship skill handles push, PR and landing.)

Stopping mid-ticket? Agents: the handoff skill saves the session state to
`handoffs/` (gitignored) so the next session can resume where you left off.

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
├── index.css            # Tailwind directives
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
