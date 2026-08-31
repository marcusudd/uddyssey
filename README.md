# Uddyssey

Shared setup for the group project so everyone works the same way, whatever
agent they use — Claude Code, OpenAI Codex or Cursor. One install into the
group repo gives everybody the same conventions, guardrails and (eventually)
skills at `git clone`.

## Layout

```
skills/        Source for all skills. Write each skill ONCE here as
               skills/<name>/SKILL.md (Agent Skills format — all three
               tools read the same format).
template/      Exactly what lands in the group repo root:
  AGENTS.md                 how we work — read by Codex and Cursor
  CLAUDE.md                 imports AGENTS.md so Claude Code reads the same
  GUIDE.md                  the team's how-to: setup per tool, the
                            workflow, what each skill does
  .claude/skills/           generated copy, read by Claude Code
  .agents/skills/           generated copy, read by Codex and Cursor
  .github/                  CI (ruff + pytest, frontend build), PR template
  .env.example              Jira credentials for the tickets skill
  .gitignore                merged into the target's own on install
  .pre-commit-config.yaml   local ruff hooks
sync.sh        skills/ → the two generated skill folders
install.sh     template/ → a target repo
```

## Install into the group repo (once, by one person)

```bash
./install.sh /path/to/group-repo
```

Then in the group repo: review with `git status`, commit, push. Everyone
else gets everything on clone — no per-person setup.

Also turn on branch protection for `main` (Settings → Branches): require a
PR, require the `backend` and `frontend` checks, require 1 approving review.

Optional per machine: `uv tool install pre-commit`, then `pre-commit install`
in the group repo.

> CI assumes a `backend/` + `frontend/` layout — paths are at the top of
> `template/.github/workflows/ci.yml` if yours differs.

## Adding or changing a skill

1. Create/edit `skills/<name>/SKILL.md` (frontmatter needs `name` and
   `description`; extra files like `references/` can sit next to it).
2. Run `./sync.sh` — regenerates both copies in `template/`.
3. Run `./install.sh /path/to/group-repo` and commit there.

Never edit the copies under `template/.claude/skills/` or
`template/.agents/skills/` — they're overwritten on every sync (each file
carries a marker saying so).
