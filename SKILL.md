---
name: projectcodeflow
description: >
  Run agentic software work as a managed project: a goal register that carries
  the goal and its part goals, a bounded alignment meeting before a unit starts,
  change control that turns anything outside the frozen plan into its own
  separate unit instead of letting it derail the work, and a gate that blocks
  delivery until the written records agree with the repository.
when-to-use: >
  project flow, projectcodeflow, goal register, part goals, sub-goals,
  alignment meeting, goal alignment, change control, change request, scope
  creep, side track, side quest, unit contract, frozen baseline, baseline hash,
  delivery gate, project management for coding agents
user-invocable: true
argument-hint: "[start|align|close|status]"
---

# Project Code Flow

A project-management layer for agentic coding work. It makes three things true in
every repository that adopts it:

1. The agent always understands the goal and the part goals, and states them back
   before it writes code.
2. Anything discovered outside the planned unit becomes its own recorded change
   with its own branch, so the active goal never stalls and never silently grows.
3. A human is involved at five named moments and nowhere else, and a gate blocks
   delivery until the written records agree with what the repository contains.

The method is deliberately tool-agnostic. It needs git, a shell, and an agent
harness that can run a script and hold a file. Nothing here depends on a specific
model, a specific vendor, or a specific orchestration framework.

## 1. The three records

All three are plain files in the repository, under a single project-management
directory (this skill uses `.pm/`; adjust once, consistently).

| Record | Path | Holds |
| --- | --- | --- |
| Goal register | `.pm/GOALS.md` | The project goal, the part goals, the unit index, each unit's acceptance criteria and status |
| Unit file | `.pm/units/U-<n>.md` | One unit's contract: goal, part goals, acceptance criteria, explicit non-goals, verification plan, branch, frozen baseline hash, status |
| Change register | `.pm/cr/CR-<n>.md` | One file per discovery outside the baseline: class, origin commit, disposition, closing commit |
| Alignment record | `.pm/meetings/<date>-unit-<n>.md` | What was restated, what a reviewer challenged, what each coder confirmed, what the human decided |

One file per change request, never one growing ledger: two branches appending to
one file conflict, and adding two files never does.

## 2. The five human decisions

Everything else is automatic. If nobody answers, the default is always the
conservative one.

| Decision | When | Default when unanswered |
| --- | --- | --- |
| Approve the goal | A new goal is introduced | Nothing starts; the draft register entry waits |
| Resolve blocking ambiguity | A unit cannot be stated unambiguously | The unit does not start; the ambiguity stays open |
| Widen the baseline | A change request argues for amending the frozen plan | Treated as a separate future unit; the active unit continues |
| One batched decision list | Unit close, only when items were parked | The items are recorded as open questions |
| Project enablement | First time in a repository | The automatic gates stay inactive |

Everything else runs without a human: log rotation, deferred and rejected change
requests, new units for accepted side tracks, the independent reviewer, the gate,
and the verification run.

## 3. The flow

Read `references/flow-en.md` (English) or `references/flow-sv.md` (Swedish) for
the step-by-step version. The short form:

1. Read the goal register. If it does not exist, write it from the stated goal and
   have it approved.
2. Restate the goal, the part goals and the non-goals. Tag every element
   UNDERSTOOD, UNCLEAR or CONFLICT.
3. If a blocking element is tagged, hold the alignment meeting: one independent
   reviewer returns four fixed fields (the acceptance command it would run, the
   biggest ambiguity it found, one thing it refuses to touch, the contract lines
   it could not map), and every coder states its own goal id and the acceptance
   command it will run. Then ask the human, once, with numbered options.
4. Write the unit contract, create the unit branch from the main line, and freeze
   the baseline: hash the acceptance-criteria block and record that hash in the
   first commit trailer and in the verification evidence, never only in the file
   the agent can rewrite.
5. Work. Anything discovered outside the frozen baseline is registered as a
   change request, classed, and dispositioned. The active unit keeps going.
6. At unit close, run the gate. Then commit with the unit trailer, review, merge.
7. Update the register and rotate the project log.

## 4. Change requests

A discovery is an implementation detail only if every file it touches is already
inside the unit's diff, it adds no new public symbol, endpoint, migration, config
key or CLI flag, and it changes no existing public signature. Everything else is a
change request.

| Disposition | Meaning | Human |
| --- | --- | --- |
| AMEND | The frozen baseline is widened, with a new hash | Yes, always |
| NEXT-UNIT | Accepted as its own unit with its own branch, worked after the current one merges | No |
| DEFER | Real but unscheduled | No |
| REJECT | Recorded with the reason | No |

This is the rule that keeps a goal from stalling: a side track never joins the
active branch, it becomes its own planned unit, and the current goal continues.

## 5. The gate

`scripts/pm-gate.sh` is the enforcement. It fails red unless:

- the active unit has a contract with acceptance criteria and a frozen hash;
- the working branch matches the unit's recorded branch;
- the recorded hash still matches the acceptance-criteria block;
- an alignment record exists for the unit;
- no change request is left undispositioned.

Wire it where your project already runs checks (`tests/run.sh`, a pre-push hook, a
CI step that skips when the checker is absent). Treat a red gate as a recorded
nonconformity, not as a retry.

`scripts/scaffold-unit.sh` creates a unit file and a change-request file from the
templates so the schema cannot drift.

## 6. Adoption in four stages

1. Records and rules only. The register, the unit file, the change register, the
   gate script. No automation, no hooks, zero infrastructure risk.
2. Automatic readout: print the active unit, the parked change requests and the
   project-log freshness at the start of a working session.
3. Pilot: run the gate retroactively over the last few completed units in two
   repositories and measure how many it would have failed, and why.
4. Widen only where the measurement shows it catches real drift rather than
   formalities.

Keep stage 1 to 4 reversible: the records are plain files, the gate is inert when
unmounted, and the whole method can be withdrawn without touching product code.

## 7. Limits, stated honestly

- A commit gate built on agent-harness hooks is a drift fence, not a security
  boundary: it can be bypassed by indirection, and hook failures generally fail
  open. Keep the script authoritative and run it directly too.
- Never pin a model in the rules or in a role definition. Providers fail, quotas
  run out, and a pinned slug takes the whole method down with it. Resolve models
  per project at runtime.
- The gate can prove that records exist and agree with the repository. It cannot
  prove that work stayed semantically inside the baseline; the unit-close diff
  review is the detector for that.
- One unit in flight at a time. Parallel branches make the baseline meaningless.

## 8. Repository contents

| Path | What |
| --- | --- |
| `references/flow-en.md` | The flow in detail, with the step table and cost model |
| `references/flow-sv.md` | The same in Swedish, with the charts embedded |
| `references/sources.md` | Every external source behind the method: the ISO catalogue pages and official previews it was written against, and the clause-level mapping. Read this before repeating any standards claim |
| `diagrams/*.mmd`, `diagrams/*.png` | The three flow diagrams, source and render |
| `presentation/board-sv.html` | A one-page board visual, self-contained and offline-safe |
| `scripts/pm-gate.sh`, `scripts/scaffold-unit.sh` | The gate and the scaffolding helper |
