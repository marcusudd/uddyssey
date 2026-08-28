---
name: rubberduck
description: Take an assigned ticket from picked-up to ready-to-implement — research the codebase, grill only the decisions code can't answer, and land the results in the ticket before any branch is cut. Use when someone picks up a ticket whose implementation decisions look unresolved, or asks to rubberduck a ticket; offer it, never run it unprompted.
---

# rubberduck

The step between picking a ticket and ship start, for tickets that
aren't fully thought through. Research first, questions second, and
everything learned lands in the ticket itself — Jira stays the single
source, and the implementer may be someone else on another harness.
Never implements.

Needs a ticket key. Without one, stop: offer tickets (create one first)
or in-loop (explore without the workflow).

## Phases

1. **Read** — fetch the ticket (read call in
   `../ticket-platform/PLATFORM.md`): summary, description, status.

2. **Research** — in-loop mode (`../in-loop/SKILL.md`): delegate
   discovery to explorer subagents, keep the main context lean. Resolve
   everything the ticket and the codebase can answer: what already
   exists, which models/services/routes/components are touched, which
   acceptance criteria are already satisfied, obsolete or too broad.
   Never ask the user what code can answer. A question the codebase
   can't answer (library behavior, API facts) → offer research
   (`../research/SKILL.md`); its note feeds the grill.

3. **Grill** — grill-me rounds (`../grill-me/SKILL.md`) on what
   remains: genuine product and implementation decisions only — which
   existing concept owns the behavior, persistence, edge cases
   (deletion, reversal, refresh), v1 or a later ticket. An answer that
   raises a new code question → back to research before the next round.

4. **Land** — draft a reconcile proposal for the tickets skill
   (`../tickets/SKILL.md`): the sharpened What & why / Acceptance
   criteria / Out of scope, plus one appended section —

       h2. Implementation notes
       * <decision, with the reason>
       * <constraint, with file references>
       * <suggested approach, a few lines at most>

   Scope changes are part of the proposal: a split becomes new tickets
   with Blocks links; a ticket that turns out already done or not worth
   building becomes a close proposal. The tickets skill's gate is the
   only path to Jira — rubberduck never calls the API itself.

## Done

Done when the proposal has passed the gate and the tickets skill has
reported the updated ticket(s) by browse URL. Then offer ship start.

## Boundary

- Never implement, never branch — that is ship's job.
- Never touch Jira directly — every write goes through the tickets gate.
- Ticket content in English, chat in the user's language — as always.
