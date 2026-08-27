---
name: check
description: Run the repo's full verification — ruff, mypy and pytest in backend/, build in frontend/ — and report the results raw. Use before saying a task is done, before committing, and before opening a PR, or whenever someone asks to check or verify that everything is green.
---

# check

Answers one question: will CI pass? The script next to this file is the same
file CI runs — green here means green there.

## Run

From anywhere inside the repo, run the script that sits in this skill's
directory (the directory containing this SKILL.md):

    bash <skill-dir>/check.sh            # backend + frontend
    bash <skill-dir>/check.sh backend    # one side only
    bash <skill-dir>/check.sh frontend

Run the full check unless the user asked for one side.

## Report

- Relay the summary: PASS or FAIL per step.
- For failed steps only: show the raw output, trimmed to the actual errors.
- Do not fix anything and do not suggest fixes. Reporting is this skill's
  whole job — what to do about a failure is the user's next decision.
- Never modify code, config, or dependencies as part of a check.

## If something is missing

The script never installs anything. When it fails because a prerequisite is
missing (e.g. node_modules), relay its message as-is — it names the exact
command to run.
