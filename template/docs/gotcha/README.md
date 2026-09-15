# Gotchas

Traps that cost someone real time, kept so nobody pays twice. One file
per category, entries as bullets.

## Where an entry goes

`docs/gotcha/<category>.md` — one file per category, not per agent or
per person, because most traps have no single owner. Categories are a
starting set, not a schema: when a trap fits none, add a file. Name it
lowercase ASCII (`git.md`, not `miljö.md`) — Windows and macOS normalise
unicode filenames differently, and a mixed team hits that.

## What an entry looks like

Each file opens with a `#` heading naming the category. Entries are
bullets that say what *happened* — the symptom, the wrong first guess,
the cause — not only what to do next time. The story is what makes the
entry findable when the symptom comes back.

Write in the language the team's docs use. An entry ships in the same
commit as the fix it came from.

## Who reads it

Before you start on an area you haven't touched, and whenever something
fails without an obvious cause. Agents: the rule lives in `AGENTS.md`
under Gotchas; the handoff skill sends month-stable traps here and keeps
the perishable ones in the handoff.
