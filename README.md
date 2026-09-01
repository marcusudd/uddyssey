# Uddyssey ⛵

A way of working for AI-assisted coding — and the setup that enforces it.
Thought comes before code: an idea is questioned until it holds, becomes a
ticket, gets a plan, and only then touches a branch. The skills in this
repo make your agent follow that road, whichever tool you or your
teammates use — Claude Code, OpenAI Codex or Cursor.

It was built for one group project, but nothing in it is specific to one.
If you're starting out with AI-coding and want structure from day one —
guardrails, a workflow, an agent that asks before it assumes — install
this into your repo and everyone who clones gets the same setup. No
per-person configuration.

The name is a nod to the Odyssey: every ticket is a small voyage, and
`main` is Ithaca 🏝️ — nothing lands there without passing the gates.

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
2026-09-01. What hasn't been confirmed yet is a skill actually firing in
Codex or Cursor; only Claude Code has been run end to end.

## Layout

```
skills/        Source for all skills — the only place you edit one.
               skills/<name>/SKILL.md, plus any files it bundles.
template/      Exactly what lands in the target repo root:
  AGENTS.md                 how we work — read by Codex and Cursor
  CLAUDE.md                 imports AGENTS.md so Claude Code reads the same
  GUIDE.md                  the team's how-to: setup per tool, the
                            workflow, what each skill does
  .claude/skills/           generated copy, read by Claude Code
  .agents/skills/           generated copy, read by Codex and Cursor
  .github/                  CI (ruff + pytest, frontend build) on every push
  plans/                    dated plan files, one per readied ticket
  .env.example              Jira credentials for the tickets skill
  .gitignore                merged into the target's own on install
  .pre-commit-config.yaml   local ruff hooks
sync.sh        skills/ → the two generated skill folders
install.sh     template/ → a target repo
```

Working files for this repo itself, not shipped anywhere: `PLAN.md`
(backlog, decisions, open points — read it before planning work),
`CLAUDE.md` (how agents should behave in *this* repo), and two gitignored
folders — `research/` (notes from background agents) and `handoffs/`
(session state).

## Install into your repo (once, by one person)

```bash
./install.sh /path/to/your-repo
```

Then in that repo: review with `git status`, commit, push. Everyone else
gets everything on clone.

The install warns if a skill on your machine shares a name with one of
this repo's — a same-named skill can shadow ours completely. Your own copy
you rename or remove; Cursor's built-in `goal` and `onboard` you can't, so
there you point the agent at the file path instead.

Optional per machine: `uv tool install pre-commit`, then `pre-commit install`
in the target repo.

> CI assumes a `backend/` + `frontend/` layout — paths are at the top of
> `template/.github/workflows/ci.yml` if yours differs.

## The voyage, step by step 🧭

Once installed, every change follows the same road. Each step is a skill —
ask your agent for it by name.

1. **Set up, once per person** 🗺️ — copy `.env.example` to `.env` and fill
   in your Jira credentials, run `gh auth login`, then ask your agent to
   run `onboard` so it learns what the codebase actually contains.
2. **Sharpen the idea** — `grill-me` asks you rounds of questions until
   nothing is left vague. No building yet.
3. **Make it a ticket** — `tickets` drafts it and creates it in Jira after
   your approval. Every change starts with a ticket.
4. **Plan it** 🦆 — `rubberduck` researches the code, asks only what the
   code can't answer, and writes a dated plan file in `plans/`. The ticket
   keeps the what and why; the plan owns the how.
5. **Set sail** ⛵ — `ship start` cuts the branch, named with the ticket
   key so Jira links the commits.
6. **Do the work** — hands-on with `in-loop`, or unattended with `goal`,
   which works the plan step by step and commits after each green check.
7. **Prove it** — `check` runs the same linters and tests CI runs. Green
   here means green there.
8. **Push** 🌊 — `ship push` shows you the commits, then pushes the
   branch. CI runs on every push.
9. **Come home** 🏝️ — `ship merge` takes the branch into `main`, only
   when you explicitly ask, and only through its four gates: local check
   green, branch CI green, your yes with the diff in front of you, and a
   clean merge.

Bracketing every session: `greet` at the start tells you where things
stand, `handoff` at the end writes down where you stopped. The installed
`GUIDE.md` tells the same story in more detail, and `AGENTS.md` is the
rulebook behind it.

## Adding or changing a skill

1. Create or edit `skills/<name>/SKILL.md`. Frontmatter needs `name` and
   `description`; keep to those two and the file stays portable across all
   three tools. Extra files (`references/`, a script) sit next to it.
2. Run `./sync.sh` — regenerates both copies in `template/`.
3. Run `./install.sh /path/to/your-repo` and commit there.

New skills get a grill session first: rounds of questions until nothing is
left assumed, then build. See `PLAN.md` for what's decided and why.

Never edit the copies under `template/.claude/skills/` or
`template/.agents/skills/` — they're overwritten on every sync, and each
file carries a marker saying so.
