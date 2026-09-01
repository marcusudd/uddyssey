# Uddyssey

Shared setup for the group project so everyone works the same way, whatever
agent they use — Claude Code, OpenAI Codex or Cursor. One install into the
group repo gives everybody the same conventions, guardrails and skills at
`git clone`.

## Why every skill exists twice

A skill is one markdown file: `SKILL.md`, with `name` and `description` in
the frontmatter. All three tools read that same format — they just don't
look in the same folder.

| Tool | Where it looks for skills |
|---|---|
| Claude Code | `.claude/skills/`, and nowhere else |
| Codex | `.agents/skills/` (its primary path), also `.codex/skills/` |
| Cursor | `.agents/skills/` and `.cursor/skills/`, plus `.claude/skills/` for compatibility |

Claude Code is the one that won't look outside its own folder, so two
generated copies is the floor, not a workaround. Write the skill once in
`skills/`, run `./sync.sh`, and both copies are rebuilt from it.

Paths confirmed against Codex's and Cursor's own documentation on
2026-09-01 — see `research/`. What hasn't been confirmed yet is a skill
actually firing in Codex or Cursor; only Claude Code has been run end to
end.

## Layout

```
skills/        Source for all skills — the only place you edit one.
               skills/<name>/SKILL.md, plus any files it bundles.
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

Working files for this repo itself, not shipped anywhere: `PLAN.md`
(backlog, decisions, open points — read it before planning work),
`research/` (notes from background agents, one file per question),
`CLAUDE.md` (how agents should behave in *this* repo), and `handoffs/`
(session state, gitignored).

## Install into the group repo (once, by one person)

```bash
./install.sh /path/to/group-repo
```

Then in the group repo: review with `git status`, commit, push. Everyone
else gets everything on clone — no per-person setup.

The install warns if a skill on your machine shares a name with one of
this repo's — a same-named skill can shadow ours completely. Your own copy
you rename or remove; Cursor's built-in `goal` and `onboard` you can't, so
there you point the agent at the file path instead.

Also turn on branch protection for `main` (Settings → Branches): require a
PR, require the `backend` and `frontend` checks, require 1 approving review.

Optional per machine: `uv tool install pre-commit`, then `pre-commit install`
in the group repo.

> CI assumes a `backend/` + `frontend/` layout — paths are at the top of
> `template/.github/workflows/ci.yml` if yours differs.

## Adding or changing a skill

1. Create or edit `skills/<name>/SKILL.md`. Frontmatter needs `name` and
   `description`; keep to those two and the file stays portable across all
   three tools. Extra files (`references/`, a script) sit next to it.
2. Run `./sync.sh` — regenerates both copies in `template/`.
3. Run `./install.sh /path/to/group-repo` and commit there.

New skills get a grill session first: rounds of questions until nothing is
left assumed, then build. See `PLAN.md` for what's decided and why.

Never edit the copies under `template/.claude/skills/` or
`template/.agents/skills/` — they're overwritten on every sync, and each
file carries a marker saying so.
