#!/usr/bin/env bash
# Copy the harness template into a target repo. Idempotent: existing files
# are overwritten with the template's version, nothing else is touched.
#
# Usage: ./install.sh /path/to/your-repo
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: ./install.sh /path/to/your-repo" >&2
  exit 1
fi
if [ ! -d "$TARGET/.git" ]; then
  echo "Error: $TARGET is not a git repository" >&2
  exit 1
fi
# Resolve the target before leaving the caller's directory — a relative
# path must mean what the caller sees, not this script's location.
TARGET="$(cd "$TARGET" && pwd)"
cd "$(dirname "$0")"
if [ "$TARGET" = "$(pwd)" ]; then
  echo "Error: refusing to install the template into its own repo" >&2
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

# A same-named skill installed on the machine can shadow the repo's entirely
# (seen live in Claude Code: the repo's onboard never appeared in the
# session's skill list). Make the collision a visible install step, not a
# silent wrong pick. Each harness reads several user-level roots, and Cursor
# additionally ships built-in skills — which collide the same way but can't
# be renamed away.
collisions_in() {
  root="$1"
  [ -d "$root" ] || return 0
  found=""
  for src in skills/*/; do
    [ -f "$src/SKILL.md" ] || continue   # ticket-platform is a reference, not a skill
    name=$(basename "$src")
    if [ -d "$root/$name" ]; then found="$found $name"; fi
  done
  if [ -n "$found" ]; then
    printf '  %s —%s\n' "${root/#$HOME/~}" "$found"
  fi
  return 0
}

personal=$(
  for root in "$HOME/.claude/skills" "$HOME/.codex/skills" \
              "$HOME/.cursor/skills" "$HOME/.agents/skills"; do
    collisions_in "$root"
  done
)
builtin=$(collisions_in "$HOME/.cursor/skills-cursor")

if [ -n "$personal" ] || [ -n "$builtin" ]; then
  echo ""
  echo "WARNING: skills on this machine share names with this repo's skills."
  echo "A same-named skill can shadow the repo's completely, and the wrong one"
  echo "may answer in the target repo."
  if [ -n "$personal" ]; then
    echo ""
    echo "Your own — rename or remove your copy:"
    echo "$personal"
  fi
  if [ -n "$builtin" ]; then
    echo ""
    echo "Cursor built-ins — these can't be removed. In Cursor, point the agent"
    echo "at the file instead: 'read .agents/skills/<name>/SKILL.md and follow it'."
    echo "$builtin"
  fi
  echo ""
fi

echo "Installed into $TARGET"
echo "Next: review with 'git status' in the target repo, then commit."
