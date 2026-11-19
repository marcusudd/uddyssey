#!/usr/bin/env bash
# The single definition of "green": every check for backend/, frontend/ and
# (when present) ml/. CI runs this same file, so passing locally means
# passing CI.
#
# Usage: check.sh [backend|frontend|ml]   (no argument = all)
#
# Runs every step even when an earlier one fails, prints a PASS/FAIL summary
# at the end, and exits non-zero if anything failed. Never installs anything.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"

SCOPE="${1:-all}"
case "$SCOPE" in
  backend|frontend|ml|all) ;;
  *) echo "Usage: check.sh [backend|frontend|ml]" >&2; exit 2 ;;
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

if [ "$SCOPE" = "backend" ] || [ "$SCOPE" = "all" ]; then
  if [ -f backend/pyproject.toml ]; then
    run_step "ruff check"  backend uv run ruff check .
    run_step "ruff format" backend uv run ruff format --check .
    run_step "mypy"        backend uv run --with mypy mypy --disallow-untyped-defs .
    run_step "pytest"      backend uv run pytest
  elif [ "$SCOPE" = "backend" ]; then
    fail_step "backend" "backend/pyproject.toml not found — this repo has no backend/ project to check yet"
  else
    echo ""
    echo "=== backend ==="
    echo "skipped — no backend/pyproject.toml yet"
  fi
fi

if [ "$SCOPE" = "frontend" ] || [ "$SCOPE" = "all" ]; then
  if [ ! -f frontend/package.json ]; then
    if [ "$SCOPE" = "frontend" ]; then
      fail_step "frontend" "frontend/package.json not found — this repo has no frontend/ project to check yet"
    else
      echo ""
      echo "=== frontend ==="
      echo "skipped — no frontend/package.json yet"
    fi
  elif [ ! -d frontend/node_modules ]; then
    fail_step "npm build" "frontend/node_modules missing — run 'npm ci' in frontend/ first"
  else
    run_step "npm build" frontend npm run build
    # Enable when the frontend has tests:
    # run_step "npm test" frontend npm test
  fi
fi

if [ "$SCOPE" = "ml" ] || [ "$SCOPE" = "all" ]; then
  if [ -f ml/pyproject.toml ]; then
    run_step "ml ruff check"  ml uv run ruff check .
    run_step "ml ruff format" ml uv run ruff format --check .
    run_step "ml mypy"        ml uv run --with mypy mypy --disallow-untyped-defs .
    run_step "ml pytest"      ml uv run pytest
  elif [ "$SCOPE" = "ml" ]; then
    fail_step "ml" "ml/pyproject.toml not found — this repo has no ml/ project to check"
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
