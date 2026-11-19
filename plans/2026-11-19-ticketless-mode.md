Ticket: none (this repo has no ticket flow) · Date: 2026-11-19 · Status: done 2026-11-19

Adds a ticketless mode to the template so solo projects can run grill →
plan → branch → check-gate without Jira, plus two fixes found while
installing into hitta_jobb. Must land before hitta_jobb's
`2026-11-19-repo-setup.md` runs.

## Steps

1. Settle the existing uncommitted WIP (`skills/check/*`,
   `template/.github/workflows/ci.yml` and their generated copies). Show
   the user the diff and ask whether it is finished; commit it as its own
   commit before anything below, or stop.
2. Project-local settings file. Template `AGENTS.md` gets a short section
   pointing at `AGENTS.project.md` in the target root: project-specific
   rules and settings live there, agents read it right after AGENTS.md.
   `install.sh` never creates or overwrites `AGENTS.project.md`; it
   prints a hint when the file is missing. `CLAUDE.md` stays
   `@AGENTS.md` and also imports `@AGENTS.project.md`.
3. Ticket source switch. `AGENTS.project.md` holds `Ticket source: jira`
   or `Ticket source: none`; missing file or line means `jira` (today's
   behavior unchanged). Document the ticketless conventions in template
   `AGENTS.md`: plan files `plans/<YYYY-MM-DD>-<slug>.md`, branches
   `feature/<slug>` / `fix/<slug>`, no Jira calls.
4. `goal`: in `none` mode accept a plan slug (or the plan file path)
   instead of a ticket key; latest date for the slug wins. Everything
   else unchanged — check per step, commit, push through ship's gates.
5. `ship`: in `none` mode start/push/merge skip the ticket fetch and key
   rules; branch named from the plan slug. Merge gate unchanged (local
   check, branch CI green, user's yes on the diff, clean `--no-ff`).
6. `rubberduck`: in `none` mode the Land phase writes only the plan file
   and skips the tickets reconcile. `tickets`: in `none` mode refuse and
   point at grill-me + a plan file.
7. Sweep the remaining skills that mention keys or Jira (`handoff`,
   `in-loop`, `grill-me`, `research`) and make their wording mode-neutral.
   `grep -rn "KEY\|Jira\|ticket key" skills/ template/AGENTS.md
   template/GUIDE.md` must only hit jira-mode text or `ticket-platform/`.
8. `check.sh`: skip backend when `backend/pyproject.toml` is missing,
   the same way `ml/` is skipped today — print "skipped", not FAIL.
   `ci.yml`: guard the backend job's steps with
   `hashFiles('backend/pyproject.toml') != ''` like the ml job.
   Same for frontend on `frontend/package.json`.
9. `GUIDE.md`: a short "Solo project without Jira" section.
   `PLAN.md`: amend the decision "Jira is the ticket source" — Jira stays
   the default, `none` is an explicit per-project opt-out.
10. `./sync.sh`, then verify: `git init` a throwaway repo in the
    scratchpad, run `install.sh` into it, confirm `AGENTS.project.md` is
    not created, a pre-existing one survives a second install, and
    `check.sh` passes in a repo with only `frontend/`.

## Decisions

- Ticketless is a mode, not a fork of the skills — one source, both
  workflows. (hitta_jobb grill Q9a: other solo projects need it too.)
- The switch lives in a file the installer never touches, so a reinstall
  can't wipe project settings. Same file carries project rules like
  "UI code follows DESIGN.md".
- Default stays `jira` so existing installs behave exactly as before.
- Missing backend/frontend is "skipped", not failure — CI must be green
  before the backend exists (hitta_jobb grill Q11).

## Out of scope

- GitHub Issues as a ticket source.
- Changing merge gates, commit rules or the plan-file shape.
- Ticket granularity and the other open points in `PLAN.md`.
