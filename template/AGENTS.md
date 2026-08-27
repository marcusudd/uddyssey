# How we work in this repo

Read this before making changes. Applies to humans and AI agents alike.

## Workflow: ticket → branch → PR

1. Every change starts with a GitHub issue (use the issue template).
2. Branch off main, named after the ticket:
   `feature/<issue#>-short-description` or `fix/<issue#>-short-description`
   (e.g. `feature/42-login-endpoint`).
3. Before pushing: run the checks locally (`/check` if you use an agent,
   otherwise `bash .agents/skills/check/check.sh`). CI runs the same script.
4. Open a PR against main. CI must be green and one teammate must approve
   before merge. Never push directly to main.

## Commits

- One logical change per commit
- Subject: imperative mood, capitalized, target 50 chars, hard limit 72,
  no period, no emojis, no `feat:`/`fix:` prefixes
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
