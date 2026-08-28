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
# .gitignore is merged, not overwritten — the target's own entries survive
if [ -f "$TARGET/.gitignore" ]; then
  cp "$TARGET/.gitignore" "$TARGET/.gitignore.pre-install"
fi
cp -R template/. "$TARGET"/
if [ -f "$TARGET/.gitignore.pre-install" ]; then
  while IFS= read -r line; do
    grep -qxF "$line" "$TARGET/.gitignore.pre-install" \
      || printf '%s\n' "$line" >> "$TARGET/.gitignore.pre-install"
  done < template/.gitignore
  mv "$TARGET/.gitignore.pre-install" "$TARGET/.gitignore"
fi
# .gitkeep files are scaffolding for this repo, not for the target
find "$TARGET/.claude/skills" "$TARGET/.agents/skills" -name .gitkeep -delete 2>/dev/null || true

# Personal skills can shadow same-named repo skills entirely (seen live in
# Claude Code: the repo's onboard never appeared in the session's skill
# list). Make the collision a visible install step, not a silent wrong pick.
PERSONAL_SKILLS="$HOME/.claude/skills"
if [ -d "$PERSONAL_SKILLS" ]; then
  collisions=""
  for src in skills/*/; do
    name=$(basename "$src")
    [ -d "$PERSONAL_SKILLS/$name" ] && collisions="$collisions $name"
  done
  if [ -n "$collisions" ]; then
    echo ""
    echo "WARNING: personal skills in ~/.claude/skills share names with repo skills:"
    echo "  $collisions"
    echo "A personal skill can shadow the repo's completely. Rename or remove the"
    echo "personal copies, or the wrong skill may answer in the target repo."
    echo ""
  fi
fi

echo "Installed into $TARGET"
echo "Next: review with 'git status' in the target repo, then commit."
