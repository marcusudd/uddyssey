---
name: research
description: Answer an external question — library behavior, API facts, specs — against primary sources via a delegated background agent, and save the answer as a durable note in research/. Use when someone asks to research a topic, or when a session hits a question the codebase can't answer; offer it, never run it unprompted.
---

# research

For questions the codebase can't answer: what a library does, what an
API supports, what a spec says. A delegated agent does the reading so
the main session's context stays lean; the answer lands as a durable
note in `research/` at the repo root.

Codebase questions are not research — they belong to in-loop or
rubberduck's research phase.

## Before spawning

Check `research/` for an existing note on the topic. One that answers
the question → report it, done. Outdated or partial → the agent
updates that file (new checked-date) instead of creating a sibling.

## The agent

One agent per question; several questions run as parallel agents, one
file each. Run it in the background where the harness supports it —
the session keeps working meanwhile — otherwise as a plain subagent.
Pick a cheaper model where the harness allows it per spawn (Claude
Code and Codex do, Cursor doesn't — see
`research/subagent-model-selection.md`): mid-tier, not bottom-tier —
tracing claims to their sources takes judgment.

The agent's job:

1. Investigate against **primary sources** — official docs, source
   code, specs, changelogs, first-party APIs — never a secondary
   write-up of them. Follow every claim back to the source that owns
   it. What can't be confirmed is said so in the note, never guessed.
2. Write one note in English to `research/<kebab-topic>.md`. No date
   in the filename — stable names let other docs reference them.

## Note shape

```markdown
# <Title>

Checked <YYYY-MM-DD>, primary sources. Question: <as posed>.

**<The answer, up front.>**

<Findings, with a source URL per claim.>
```

No YAML frontmatter.

## Done

Relay the file path and the TL;DR. Never commit — that's the user's
call. If the question served a ticket discussion, offer to fold the
conclusion into the ticket via the tickets gate (or the running
rubberduck flow) — no automatic coupling.

## Boundary

- Codebase questions → in-loop / rubberduck
- Never commits, never touches Jira
- Notes in English, chat in the user's language — as always
