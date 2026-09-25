#!/usr/bin/env bash
# pm-gate.sh — delivery gate for the project-code-flow method.
#
# The gate is the authority. A commit fence built on agent-harness hooks is a
# convenience: hook failures generally fail open, so this script must be able to
# run on its own, at commit time and in CI.
#
# It fails red unless the written records agree with the repository:
#   1. the goal register exists
#   2. exactly one unit is marked active (never two units in flight)
#   3. the active unit declares acceptance criteria
#   4. the working branch matches the unit record, and is not a protected line
#   5. the frozen baseline hash still matches the acceptance-criteria block
#   6. that same hash is anchored in a commit trailer (Baseline: <hash>), so
#      rewriting the record cannot pass the gate
#   7. an alignment record exists for the unit
#   8. no change request is left undispositioned
#
# Usage:  bash scripts/pm-gate.sh [--pm-dir .pm] [--trust-file FILE] [--strict-trust]
# Exit:   0 = pass, 1 = fail, 3 = skipped (no records in this repository)

set -uo pipefail

PM_DIR=".pm"
TRUST_FILE=""
STRICT_TRUST=0

while [ $# -gt 0 ]; do
  case "$1" in
    --pm-dir) PM_DIR="$2"; shift 2 ;;
    --trust-file) TRUST_FILE="$2"; shift 2 ;;
    --strict-trust) STRICT_TRUST=1; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "pm-gate: unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ ! -d "$PM_DIR" ]; then
  echo "pm-gate: SKIP  no $PM_DIR directory in this repository"
  exit 3
fi

failures=0
warnings=0
check() { if eval "$2"; then echo "PASS  $1"; else echo "FAIL  $1"; failures=$((failures + 1)); fi; }
warn()  { echo "WARN  $1"; warnings=$((warnings + 1)); }

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
live_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

register="$PM_DIR/GOALS.md"
check "goal register exists ($register)" "[ -f '$register' ]"

# --- exactly one active unit -------------------------------------------------
active_files=$(grep -l -E '^status:[[:space:]]*active' "$PM_DIR"/units/U-*.md 2>/dev/null | wc -l | tr -d ' ')
check "exactly one unit is marked active (found ${active_files:-0})" "[ '${active_files:-0}' -le 1 ]"

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
  check "working branch matches the unit record (${recorded_branch:-unset} vs ${live_branch:-none})" \
    "[ -n '${recorded_branch:-}' ] && [ '${recorded_branch}' = '${live_branch}' ]"

  case "$live_branch" in
    main|master|dev|development|trunk)
      echo "FAIL  the working branch is a protected integration line"
      failures=$((failures + 1)) ;;
  esac

  recorded_hash=$(awk -F'[:[:space:]]+' '/^baseline_hash:/{print $2; exit}' "$active_unit" 2>/dev/null)
  if [ -n "${recorded_hash:-}" ] && [ "$recorded_hash" != "TO-BE-FROZEN" ]; then
    live_hash=$(awk '/^##[[:space:]]+Acceptance criteria/{f=1;next} /^##[[:space:]]/{f=0} f' "$active_unit" \
      | sed -e 's/[[:space:]]\+$//' -e '/^$/d' | git hash-object --stdin)
    check "frozen baseline hash still matches the acceptance criteria" \
      "[ '${recorded_hash}' = '${live_hash}' ]"

    # The anchor: the same hash, inside a commit trailer on this branch. A record
    # that a writer can rewrite cannot be the only place the frozen value lives.
    check "baseline hash is anchored in a commit trailer (Baseline: ${recorded_hash:0:12}...)" \
      "git log --format=%B -n 500 2>/dev/null | grep -q '^Baseline: ${recorded_hash}$'"
  else
    echo "FAIL  no frozen baseline_hash recorded in $active_unit"
    failures=$((failures + 1))
  fi

  meeting_count=$(ls -1 "$PM_DIR"/meetings/*"$unit_id"* 2>/dev/null | wc -l | tr -d ' ')
  check "an alignment record exists for $unit_id" "[ '${meeting_count:-0}' -gt 0 ]"
fi

# --- change register ---------------------------------------------------------
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

# --- absence must be loud ----------------------------------------------------
# Repository-local agent hooks and repository-local automation can be silently
# skipped unless the folder is trusted, so a gate that is never reached looks
# exactly like a gate that passed. Pass the harness's trust store with
# --trust-file; the check is advisory unless --strict-trust is given.
if [ -n "$TRUST_FILE" ]; then
  if [ ! -f "$TRUST_FILE" ]; then
    warn "trust store not found at $TRUST_FILE — cannot confirm the gates are active"
  elif [ -n "$repo_root" ] && ! grep -q "$repo_root" "$TRUST_FILE" 2>/dev/null; then
    if [ "$STRICT_TRUST" -eq 1 ]; then
      echo "FAIL  $repo_root is not in $TRUST_FILE: repository-local gates may never run"
      failures=$((failures + 1))
    else
      warn "$repo_root is not in $TRUST_FILE: repository-local gates may never run"
    fi
  else
    echo "PASS  repository-local gates are trusted for this folder"
  fi
fi

echo
if [ "$failures" -eq 0 ]; then
  if [ "$warnings" -gt 0 ]; then
    echo "pm-gate: overall PASS (with $warnings warning(s))"
  else
    echo "pm-gate: overall PASS"
  fi
  exit 0
fi
echo "pm-gate: $failures check(s) failed — fix the records before delivering"
exit 1
