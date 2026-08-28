# Ticket platform — Jira Cloud

The one place that knows how to talk to the ticket platform. Skills
(tickets, ship) describe their workflow and point here for every API
call. Switching platforms later means rewriting this file (and
`.env.example`) — the skills stay untouched.

Not a skill — there is no SKILL.md here, nothing to invoke. Reference
material only.

## Credentials

Every call needs four env vars: `JIRA_BASE_URL`, `JIRA_EMAIL`,
`JIRA_API_TOKEN`, `JIRA_PROJECT_KEY`. If they aren't exported, load them
from `.env` at the repo root inside the same shell command:

    set -a; source .env; set +a; curl ...

If there is no `.env` either, stop and point the user at `.env.example`:
copy it to `.env`, fill it in, token from
https://id.atlassian.com/manage-profile/security/api-tokens. Keep the
token out of everything you print.

Auth on every call: `-u "$JIRA_EMAIL:$JIRA_API_TOKEN"` plus
`-H "Content-Type: application/json"`.

## Linking — how code reaches the ticket

The Jira–GitHub integration links branches, commits and PRs to a ticket
through the ticket key in the branch name — uppercase (`PROJ-123`,
never `proj-123`). A branch named `feature/PROJ-123-...` is enough: its
commits and its PR show up on the ticket automatically. No key means no
link, and it fails silently. GitHub issues are not synced at all — Jira
is the only ticket source.

## Read a ticket

    curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
      "$JIRA_BASE_URL/rest/api/2/issue/<KEY>?fields=summary,description,issuetype,status"

## Create a ticket

    curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" -H "Content-Type: application/json" \
      -X POST "$JIRA_BASE_URL/rest/api/2/issue" \
      -d '{"fields": {"project": {"key": "'"$JIRA_PROJECT_KEY"'"},
           "issuetype": {"name": "Story"},
           "summary": "As a ..., we need ..., so we can ...",
           "description": "h2. What & why\n..."}}'

Descriptions are Atlassian wiki markup (`h2.` headings, `*` bullets).
Use API v2 for anything with a description — v2 takes it as a plain
wiki-markup string, v3 demands ADF JSON. New issues land in the backlog
on their own — nothing to add to a sprint.

## Link tickets

For "A blocks B", A is the outward issue:

    curl ... -X POST "$JIRA_BASE_URL/rest/api/2/issueLink" \
      -d '{"type": {"name": "Blocks"},
           "outwardIssue": {"key": "<A>"}, "inwardIssue": {"key": "<B>"}}'

## Search open tickets

    curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" --get \
      "$JIRA_BASE_URL/rest/api/3/search/jql" \
      --data-urlencode "jql=project = $JIRA_PROJECT_KEY AND statusCategory != Done" \
      --data-urlencode "fields=summary,status"

(The older `/rest/api/2/search` endpoint was removed in 2025 — search is
the one call that has to go through v3.)

## Update and transition

Update fields: `PUT /rest/api/2/issue/<KEY>` with the same fields shape
as create. Status moves go through transitions: `GET
.../issue/<KEY>/transitions`, then POST the id of the transition whose
target status matches (e.g. status category Done to close).

## Reporting

A ticket's browse URL is `$JIRA_BASE_URL/browse/<KEY>` — use it whenever
a ticket is reported back to the user.
