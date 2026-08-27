#!/usr/bin/env bash
# The single definition of "green": every check for backend/ and frontend/.
# CI runs this same file, so passing locally means passing CI.
#
# Usage: check.sh [backend|frontend]   (no argument = both)
#
# Runs every step even when an earlier one fails, prints a PASS/FAIL summary
# at the end, and exits non-zero if anything failed. Never installs anything.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"

SCOPE="${1:-all}"
case "$SCOPE" in
  backend|frontend|all) ;;
  *) echo "Usage: check.sh [backend|frontend]" >&2; exit 2 ;;
esac

names=()
results=()

run_step() { # run_step <name> <dir> <cmd...>
  local name="$1" dir="$2"
  shift 2
  echo ""
  echo "=== $name ==="
  if (cd "$dir" && "$@"); then
    results+=(PASS)
  else
    results+=(FAIL)
  fi
  names+=("$name")
}

fail_step() { # fail_step <name> <message>
  echo ""
  echo "=== $1 ==="
  echo "$2"
  names+=("$1")
  results+=(FAIL)
}

if [ "$SCOPE" != "frontend" ]; then
  if [ -d backend ]; then
    run_step "ruff check"  backend uv run ruff check .
    run_step "ruff format" backend uv run ruff format --check .
    run_step "mypy"        backend uv run --with mypy mypy --disallow-untyped-defs .
    run_step "pytest"      backend uv run pytest
  else
    fail_step "backend" "backend/ not found — this script expects the repo's backend/ + frontend/ layout"
  fi
fi

if [ "$SCOPE" != "backend" ]; then
  if [ ! -d frontend ]; then
    fail_step "frontend" "frontend/ not found — this script expects the repo's backend/ + frontend/ layout"
  elif [ ! -d frontend/node_modules ]; then
    fail_step "npm build" "frontend/node_modules missing — run 'npm ci' in frontend/ first"
  else
    run_step "npm build" frontend npm run build
    # Enable when the frontend has tests:
    # run_step "npm test" frontend npm test
  fi
fi

echo ""
echo "=== summary ==="
status=0
for i in "${!names[@]}"; do
  printf '%s  %s\n' "${results[$i]}" "${names[$i]}"
  if [ "${results[$i]}" = FAIL ]; then
    status=1
  fi
done
exit "$status"
