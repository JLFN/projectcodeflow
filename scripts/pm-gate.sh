#!/usr/bin/env bash
# pm-gate.sh — delivery gate for the project-code-flow method.
#
# Fails red unless the written records agree with the repository:
#   1. the active unit has a contract with acceptance criteria
#   2. the recorded branch matches the working branch
#   3. the frozen baseline hash still matches the acceptance-criteria block
#   4. an alignment record exists for the unit
#   5. no change request is left undispositioned
#
# Usage:  bash scripts/pm-gate.sh [--pm-dir .pm]
# Exit:   0 = pass, 1 = fail, 3 = skipped (no records in this repository)
#
# It is deliberately a plain shell script: no dependencies beyond git, awk and grep.

set -uo pipefail

PM_DIR=".pm"
while [ $# -gt 0 ]; do
  case "$1" in
    --pm-dir) PM_DIR="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "pm-gate: unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ ! -d "$PM_DIR" ]; then
  echo "pm-gate: SKIP  no $PM_DIR directory in this repository"
  exit 3
fi

failures=0
check() { if eval "$2"; then echo "PASS  $1"; else echo "FAIL  $1"; failures=$((failures + 1)); fi; }

register="$PM_DIR/GOALS.md"
check "goal register exists ($register)" "[ -f '$register' ]"

# The active unit is the one marked active in the register, or the newest unit file.
active_unit=""
if [ -d "$PM_DIR/units" ]; then
  active_unit=$(grep -l -E '^status:[[:space:]]*active' "$PM_DIR"/units/U-*.md 2>/dev/null | sort | tail -1)
  if [ -z "$active_unit" ]; then
    active_unit=$(ls -1 "$PM_DIR"/units/U-*.md 2>/dev/null | sort -V | tail -1)
  fi
fi
check "an active unit file exists" "[ -n '$active_unit' ]"

if [ -n "${active_unit:-}" ] && [ -f "$active_unit" ]; then
  unit_id=$(basename "$active_unit" .md)
  echo "INFO  active unit: $unit_id"

  check "unit declares acceptance criteria" \
    "grep -q -E '^##[[:space:]]+Acceptance criteria' '$active_unit'"

  recorded_branch=$(awk -F'[:[:space:]]+' '/^branch:/{print $2; exit}' "$active_unit" 2>/dev/null)
  live_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  check "working branch matches the unit record (${recorded_branch:-unset} vs ${live_branch:-none})" \
    "[ -n '${recorded_branch:-}' ] && [ '${recorded_branch}' = '${live_branch}' ]"

  if [ -n "${recorded_branch:-}" ]; then
    case "$live_branch" in
      main|master|dev|development)
        echo "FAIL  the working branch is a protected integration line"
        failures=$((failures + 1)) ;;
    esac
  fi

  recorded_hash=$(awk -F'[:[:space:]]+' '/^baseline_hash:/{print $2; exit}' "$active_unit" 2>/dev/null)
  if [ -n "${recorded_hash:-}" ]; then
    live_hash=$(awk '/^##[[:space:]]+Acceptance criteria/{f=1;next} /^##[[:space:]]/{f=0} f' "$active_unit" \
      | sed -e 's/[[:space:]]\+$//' -e '/^$/d' | git hash-object --stdin)
    check "frozen baseline hash still matches the acceptance criteria" \
      "[ '${recorded_hash}' = '${live_hash}' ]"
  else
    echo "FAIL  no baseline_hash recorded in $active_unit"
    failures=$((failures + 1))
  fi

  meeting_count=$(ls -1 "$PM_DIR"/meetings/*"$unit_id"* 2>/dev/null | wc -l | tr -d ' ')
  check "an alignment record exists for $unit_id" "[ '${meeting_count:-0}' -gt 0 ]"
fi

if [ -d "$PM_DIR/cr" ]; then
  undisposed=0
  for cr in "$PM_DIR"/cr/CR-*.md; do
    [ -f "$cr" ] || continue
    if ! grep -q -E '^disposition:[[:space:]]*(AMEND|NEXT-UNIT|DEFER|REJECT)' "$cr"; then
      echo "FAIL  $cr has no valid disposition"
      undisposed=$((undisposed + 1))
    fi
  done
  check "no change request is left undispositioned" "[ '$undisposed' -eq 0 ]"
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "pm-gate: overall PASS"
  exit 0
fi
echo "pm-gate: $failures check(s) failed — fix the records before delivering"
exit 1
