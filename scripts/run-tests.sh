#!/usr/bin/env bash
# =============================================================================
# PostgreSQL Index Lab - evaluator runner
# =============================================================================
# Runs the challenge evaluators and exits non-zero if any of them fails.
#
#   ./scripts/run-tests.sh          # all challenges
#   ./scripts/run-tests.sh 04       # only challenge 04
#
# The evaluators run as `postgres` (not as `student`) so that role/database
# level planner settings cannot influence the measured plans.
# =============================================================================
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

COMPOSE="${COMPOSE:-docker compose}"
SERVICE="${SERVICE:-db}"
DB="${SCHEMA_DB:-indexlab}"
FILTER="${1:-}"

if ! $COMPOSE ps "$SERVICE" >/dev/null 2>&1; then
  echo "PostgreSQL is not running. Start it with: docker compose up -d" >&2
  exit 2
fi

failures=0
ran=0

for file in $(ls -1 tests/challenge-*.sql | sort); do
  num="$(basename "$file" | sed 's/challenge-//; s/\.sql//')"
  if [ -n "$FILTER" ] && [ "$num" != "$FILTER" ]; then
    continue
  fi

  ran=$((ran + 1))
  output="$($COMPOSE exec -T "$SERVICE" psql -U postgres -d "$DB" -q -f - < "$file" 2>&1)"
  status=$?

  echo "$output"

  if [ $status -ne 0 ]; then
    echo "Challenge $num: evaluator error (see above)" >&2
    failures=$((failures + 1))
  elif ! grep -q "Status: PASSED" <<< "$output"; then
    failures=$((failures + 1))
  fi
done

if [ "$ran" -eq 0 ]; then
  echo "No challenge matched '${FILTER}'." >&2
  exit 2
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "All $ran challenge(s) PASSED."
  exit 0
else
  echo "$failures of $ran challenge(s) FAILED."
  exit 1
fi
