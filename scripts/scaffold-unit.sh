#!/usr/bin/env bash
# scaffold-unit.sh — create a unit file and a change-request file from templates.
#
# Usage:
#   bash scripts/scaffold-unit.sh unit  "<goal one-liner>" [pm-dir]
#   bash scripts/scaffold-unit.sh cr    "<discovery one-liner>" [pm-dir]
#
# The scaffold exists so the record schema cannot drift: the gate checks fields by
# name, and a hand-written file that renames a field fails at the worst moment.

set -euo pipefail

kind="${1:-}"
title="${2:-}"
PM_DIR="${3:-.pm}"

if [ -z "$kind" ] || [ -z "$title" ]; then
  sed -n '2,12p' "$0"
  exit 1
fi

mkdir -p "$PM_DIR/units" "$PM_DIR/cr" "$PM_DIR/meetings"

next_number() {
  local dir="$1" prefix="$2"
  local last
  last=$(ls -1 "$dir"/${prefix}-*.md 2>/dev/null | sed -E "s/.*${prefix}-([0-9]+)\.md/\1/" | sort -n | tail -1)
  echo "$(( ${last:-0} + 1 ))"
}

case "$kind" in
  unit)
    n=$(next_number "$PM_DIR/units" U)
    file="$PM_DIR/units/U-$n.md"
    slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed -e 's/-\+/-/g' -e 's/^-//' -e 's/-$//' | cut -c1-40)
    cat > "$file" <<EOF
---
unit: U-$n
status: active
branch: feature/$slug
baseline_hash: TO-BE-FROZEN
---

# U-$n — $title

## Goal

$title

## Part goals

- (one line per part goal, each with the acceptance command that proves it)

## Acceptance criteria

- (the checkable statements the unit is judged against; the frozen hash is taken
  over exactly this block)

## Non-goals

- (what this unit explicitly will not touch)

## Verification plan

- (the commands to run, and the independent verification to request)

## Notes

- created by scripts/scaffold-unit.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    hash=$(awk '/^## Acceptance criteria$/{f=1;next} /^## /{f=0} f' "$file" \
      | sed -e 's/[[:space:]]\+$//' -e '/^$/d' | git hash-object --stdin)
    sed -i.bak "s/^baseline_hash:.*/baseline_hash: $hash/" "$file" && rm -f "$file.bak"
    echo "created $file"
    echo "baseline hash: $hash"
    echo "record it in the first commit trailer as:  Baseline: $hash"
    ;;

  cr)
    n=$(next_number "$PM_DIR/cr" CR)
    file="$PM_DIR/cr/CR-$n.md"
    origin=$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")
    cat > "$file" <<EOF
---
cr: CR-$n
status: open
class: TO-BE-CLASSED
discovered_at: $origin
unit: TO-BE-FILLED
disposition: 
---

# CR-$n — $title

## What was found

$title

## Why it is outside the active baseline

- (name the file, symbol, endpoint, migration, config key or CLI flag)

## Effort guess

- (small, medium, large)

## Decision

- disposition: (AMEND | NEXT-UNIT | DEFER | REJECT)
- decided by:
- closing unit, branch and commit (fill in when closed):
EOF
    echo "created $file"
    echo "an open change request with no disposition fails the gate"
    ;;

  *)
    echo "unknown kind: $kind (expected unit or cr)" >&2
    exit 1
    ;;
esac
