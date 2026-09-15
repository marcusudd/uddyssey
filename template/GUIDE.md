# The agent guide

This repo ships a set of **skills** — small instruction files your AI agent
reads so that everyone on the team works the same way, whatever tool they
use. This page is the map: how to set it up, what the workflow is, and
which skill to reach for when.

`AGENTS.md` is the rulebook (how we commit, where files go). This is the
how-to.

---

## 1. Setup

### Once per project, by one person

The template is already installed if you can see this file. What still has
to be switched on by hand:

- **The Jira–GitHub integration**, at the org level. Without it, branch
  names don't link commits to tickets.

There are no PRs and no branch protection in this workflow — main is
guarded by the ship skill's merge gate instead (see the workflow below).

### Once per person, after you clone

Four steps. The first two take a minute; skip them and your first ticket
command fails.

1. **Jira credentials.** `cp .env.example .env`, then fill in the four
   values. The token comes from
   <https://id.atlassian.com/manage-profile/security/api-tokens>.
   `.env` is gitignored — never commit it.
2. **GitHub CLI.** `gh auth login`. Ship's merge mode uses it to
   verify the branch's CI run is green before anything reaches main.
3. **Ask your agent to run `onboard`.** It scans the codebase and writes a
   short "what's actually built" brief. The brief is stored inside your
   local `.git/` folder, so it is *not* shared — everyone runs this once.
4. **Optional:** `uv tool install pre-commit && pre-commit install` for
   local lint hooks.

You also need `uv` (backend) and Node 22 (frontend) on your machine — the
same tools CI uses.

### Per tool

| Tool | What it reads | What you do |
|---|---|---|
| **Claude Code** | `.claude/skills/` and `CLAUDE.md` (which imports `AGENTS.md`) | Nothing. It works on clone. |
| **Codex** | `AGENTS.md` at the repo root, skills in `.agents/skills/` | Nothing to configure. |
| **Cursor** | `AGENTS.md`, skills in `.agents/skills/` | Nothing to configure. |

`SKILL.md` is an open format all three tools implement — the same file
works everywhere, only the folder they look in differs. That's why the
repo ships two copies of every skill: Claude Code reads `.claude/skills/`
and nothing else, Codex reads `.agents/skills/`, and Cursor reads both.

Two honest caveats:

- **Only Claude Code has been run end to end.** The paths above come from
  Codex's and Cursor's own docs, but nobody has watched a skill fire in
  those two yet. If one doesn't trigger, point your tool at the file
  directly: "read `.agents/skills/ship/SKILL.md` and follow it."
- **Personal skills can hide the repo's.** If you have your own skill with
  the same name (e.g. a personal `research`), it may shadow this repo's
  copy completely. The repo's copy governs — rename or remove your
  personal one. Cursor users: it ships built-in skills called `goal` and
  `onboard`, which collide with two of ours.

---

## 2. The workflow

Every change follows the same road:

```
   idea  →  grill-me  →  tickets  →  [ rubberduck → plan file ]  →  ship start
                                                                        ↓
              handoff  ←  ship merge  ←  ship push  ←  check  ←  the work
                          (only when                             (in-loop
                           you ask)                               or goal)
```

Two skills run *inside* others rather than beside them: grill-me powers
rubberduck's question rounds, and ship's start/push/merge modes are what
goal calls at its edges. If two skills feel like they do the same thing,
that is usually why.

In words:

1. **An idea gets sharpened before it becomes work.** `grill-me` asks you
   the questions you skipped.
2. **`tickets` turns the settled plan into Jira tickets.** Nothing is
   created until you approve the exact wording. Jira is the only ticket
   source — we don't use GitHub issues.
3. **If a ticket is vague, `rubberduck` makes it ready** before any branch
   exists: it researches the code, asks only what the code can't answer,
   and lands the outcome as a dated plan file in `plans/` — the ticket
   keeps the what and why, the file owns the how.
4. **`ship start` creates the branch**, named with the Jira key in
   uppercase (`feature/PROJ-123-csv-export`). That key is what links your
   commits to the ticket — get it wrong and the link silently never
   happens.
5. **Do the work.** Either hands-on (`in-loop` when you're exploring) or
   unattended (`goal`, if the ticket already has a plan file). Agents
   commit to the branch automatically after each green check.
6. **`check` before you claim anything works.** It runs the same script CI
   runs, so green here means green there.
7. **`ship push` gets the branch to origin.** Proposed when something is
   achieved, always check-gated — and you see the commits before anything
   leaves your machine. CI runs on every branch push.
8. **`ship merge` takes it into main — only when you ask.** Four gates,
   all mandatory: local check green, branch CI green, your yes with the
   diff on screen — given before main changes at all — and a clean
   merge (any conflict stops it). Regular merges, no squash — old
   branches stay safe to delete.

Bracketing all of it: **`greet`** at the start of a session tells you where
things stand, **`handoff`** at the end writes down where you stopped.
**`research`** can be called at any point for an outside fact, and
**`explain`** whenever an answer didn't land. A trap that cost you real
time goes into `docs/gotcha/<category>.md` with the fix, so the next
person doesn't pay for it twice.

You move the Jira card across the board yourself. No skill does it for you
— the one exception is `tickets`, which can close an obsolete ticket, and
only after you approve.

---

## 3. The skills

**Every session**

| Skill | What it does |
|---|---|
| `greet` | Reads the brief, your last handoff and git status, then tells you in a few lines where things stand. Run it first, always. |
| `handoff` | Writes down exactly where you stopped, so the next session resumes without re-digging. Ask for it before you close the laptop. |

**Deciding what to build**

| Skill | What it does |
|---|---|
| `grill-me` | Interviews you round by round about a plan, pressing on everything left vague, until nothing is silently assumed. |
| `tickets` | Turns an agreed plan — or a rough idea — into properly worded Jira tickets. Creates nothing without your go-ahead. |
| `rubberduck` | Takes a ticket that isn't thought through, researches the code, settles the open decisions with you, and writes them into the ticket. |

**Doing the work**

| Skill | What it does |
|---|---|
| `in-loop` | A no-ticket, no-process mode for poking around, chasing a bug, or trying an idea out. |
| `goal` | Runs a ticket that already has a plan file from branch to pushed branch unattended, stopping only for a real decision. Never merges to main. |
| `check` | Runs the project's linters and tests — the same ones CI runs — and reports pass or fail. Never fixes anything itself. |
| `ship` | Gets the work in: creates the branch, pushes, and — only on your explicit ask — merges into main through the four-point gate. |

**Support**

| Skill | What it does |
|---|---|
| `research` | Answers a question the code can't — how a library behaves, what an API supports — and saves the answer in `research/`. |
| `explain` | Takes the agent's last answer and explains it more simply, one step at a time, until it lands. Cursor users: Option+Enter pins it for the whole chat instead of one message. |
| `onboard` | Scans the codebase and writes the short "what's built" brief that `greet` reads. Run once after cloning. |
| `ticket-platform` | Not a skill you invoke. It's the reference sheet of Jira calls the other skills use. |

---

## 4. Which one do I use?

Three pairs are easy to mix up.

**`ship` or `goal`?**
Both move a ticket forward. `ship` does one step at a time and you drive.
`goal` does the whole run by itself — but only if the ticket already has a
plan file in `plans/`. No plan file, no `goal`. Both end at a pushed
branch: merging to main is always a separate, explicit ask.

**`grill-me` or `rubberduck`?**
`grill-me` questions *anything* — a plan, an architecture choice, a library
pick. `rubberduck` is specifically a ticket that isn't ready: it researches
the code first and only asks you what the code couldn't answer. Got a
ticket key? Use `rubberduck`. No ticket yet? `grill-me`.

**`in-loop` or `goal`?**
`in-loop` is for when you don't know the answer yet and want to explore
together. `goal` is for when the answer is already written down and you
want it executed.

**A test went red — now what?**
`check` reports, never fixes. If you know the cause, just fix it. If you
don't, go to `in-loop`, which insists on reproducing the bug before
touching a fix. If it turns out to be bigger work, it becomes a ticket.

---

## 5. Words we use

- **Gate** — a stop where the agent shows you what it's about to do and
  waits for a yes. Nothing reaches Jira, GitHub or `main` without passing
  one.
- **Frontier** (`grill-me`) — the questions that can be asked right now,
  because everything they depend on is already settled.
- **Vertical slice** (`tickets`) — a ticket you can demo on its own,
  cutting through route, service and UI. A ticket nobody can demo is two
  half-tickets.
- **Reconcile** (`tickets`) — re-checking open tickets against a plan that
  has since changed, and proposing what to create, update or close.
- **Plan file** (`plans/`) — a dated, committed file
  (`2026-09-01-PROJ-123-csv-export.md`) owning a ticket's "how": Steps,
  Decisions, Out of scope. Written by `rubberduck`, worked by `goal`,
  closed by `ship merge` with a "Merged to main" line. A re-grill writes
  a new dated file; old ones stay as history.
- **The brief** (`onboard`) — the short summary of what exists in the
  codebase, kept in your local `.git/` folder.
- **Handoff** — your personal end-of-session note in `handoffs/`. It is
  gitignored, so it never reaches your teammates. Anything *they* need
  belongs in Jira or the repo (the ticket, the plan file, the branch).
- **Gotcha** (`docs/gotcha/`) — a committed, shared trap: what happened,
  what the wrong first guess was, what fixed it. One file per category.
  The handoff keeps what rots; this keeps what stays true.
