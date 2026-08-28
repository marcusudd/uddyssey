# uddyssey

Agents: at session start, use the greet skill before anything else. When
the session is winding down, offer the handoff skill.

Skills are edited in `skills/` (the source) — never in the generated
copies under `template/`. See README.md.

Backlog, decisions and open points live in `PLAN.md` — read it before
planning work, update it when a decision lands. Session state goes
through the handoff skill into `handoffs/` (gitignored).

## How we work here

- Answer in the language the user writes in.
- New skills go through a grill session first: rounds of numbered
  questions with a recommended answer per question. Build nothing until
  the frontier is empty and the user has confirmed.
- Ask instead of assuming. Keep it simple — cut complexity when in
  doubt.
- Research is done by background agents against primary sources →
  `research/*.md`.
