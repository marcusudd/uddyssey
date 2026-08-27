#!/usr/bin/env bash
# Copy the harness template into a target repo. Idempotent: existing files
# are overwritten with the template's version, nothing else is touched.
#
# Usage: ./install.sh /path/to/group-repo
set -euo pipefail
cd "$(dirname "$0")"

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: ./install.sh /path/to/group-repo" >&2
  exit 1
fi
if [ ! -d "$TARGET/.git" ]; then
  echo "Error: $TARGET is not a git repository" >&2
  exit 1
fi

./sync.sh
cp -R template/. "$TARGET"/
# .gitkeep files are scaffolding for this repo, not for the target
find "$TARGET/.claude/skills" "$TARGET/.agents/skills" -name .gitkeep -delete 2>/dev/null || true

echo "Installed into $TARGET"
echo "Next: review with 'git status' in the target repo, then commit."
