# The flow in detail

This is the step-by-step description of the method. It is tool-agnostic: "the
harness" is whatever agent tool runs the work, "the gate" is
`scripts/pm-gate.sh`, and the records are plain files in `.pm/`.

- `diagrams/flow-lifecycle.png` — the whole loop, from session start to the next session.
- `diagrams/flow-change-control.png` — a discovery during a unit and where it goes.
- `diagrams/flow-decisions.png` — the five moments a human is needed, and everything that runs without one.

Source for each diagram is the `.mmd` file next to it.

## 1. The lifecycle

![The lifecycle from session start to the next session](../diagrams/flow-lifecycle.png)

| # | Step | Who | Mechanism | Human | Failure mode and guard |
| --- | --- | --- | --- | --- | --- |
| 1 | A working session starts in the repository | human | any harness, started in the project root | no | started elsewhere, the readout finds no register |
| 2 | The readout line is written into the project log | harness | start hook or a script that appends a line | no | not a git repository: warn loudly instead of continuing silently |
| 3 | The goal register is read | agent | `.pm/GOALS.md` | no | missing register is created first, see step 4 |
| 4 | The goal and part goals are written and approved | agent + human | register file plus one question with numbered options | yes, once per new goal | nothing starts without approval |
| 5 | The goal, part goals and non-goals are restated | agent | every element tagged UNDERSTOOD, UNCLEAR or CONFLICT | no | an untagged element may not pass |
| 6 | A blocking ambiguity is settled | agent, reviewer, coders, human | one independent reviewer returning four fixed fields; each coder states its own goal id and acceptance command; one numbered question | yes, when blocking | non-blocking ambiguity is recorded and batched to unit close |
| 7 | Unit contract, branch and frozen baseline | agent | branch from the main line; hash of the acceptance criteria recorded in the first commit trailer | no | a hash stored only next to the text it protects is self-attested |
| 8 | The unit is worked | coders | ordinary rules for build, tests and verification | no | each coder records its own confirmation; the gate checks the text |
| 9 | Something outside the baseline is found | anyone | change request registered, work continues | only for AMEND | laundering the change into the acceptance criteria is the main risk |
| 10 | Unit verification | agent + verifier | tests, build, independent verification record | no | the verification must be fresh against the pushed state |
| 11 | The gate runs | agent or hook | `scripts/pm-gate.sh` | no | a red gate is a recorded nonconformity, not a silent retry |
| 12 | Commit, review, merge | agent + human | one commit trailer naming the unit | review, as usual | never commit directly to the main line |
| 13 | One batched decision list | agent + human | numbered options in a single question | only if items were parked | ask once, not per item |
| 14 | Register updated, project log rotated | agent | plain file writes | no | two writers drift apart; the gate compares the active unit id |
| 15 | Context check, then continue | agent | usage read from the harness, if it exposes it | no | do not stop a multi-unit project far below the rotation threshold |

## 2. A discovery during a unit

![A discovery during a unit and its dispositions](../diagrams/flow-change-control.png)

A discovery is an implementation detail only if all of the following hold: every
file it touches is already in the unit's diff, it adds no new public symbol,
endpoint, migration, config key or CLI flag, and it changes no existing public
signature. Otherwise it is a change request.

| Disposition | Meaning | Human |
| --- | --- | --- |
| AMEND | The frozen baseline is widened; requires a fresh hash and a recorded approval | yes, always |
| NEXT-UNIT | Its own unit, its own branch from the main line, after the current unit merges | no |
| DEFER | Real, unscheduled | no |
| REJECT | Recorded with the reason | no |

When a change request closes, the unit id, branch and closing commit are recorded,
so the chain change to unit to branch to commits to verification evidence is
readable from git alone.

## 3. The five human decisions

![The five human decisions and everything that runs without one](../diagrams/flow-decisions.png)

| Decision | When | What is asked | Default when unanswered |
| --- | --- | --- | --- |
| Approve the goal | A new goal is introduced | Goal, part goals, acceptance criteria, non-goals | Nothing starts; the draft waits |
| Blocking ambiguity | A unit cannot be stated unambiguously | A numbered list of the alternative readings | The unit does not start; the ambiguity stays open |
| AMEND | A change request argues for widening the baseline | Widen or not | Treated as a future unit; work continues |
| Batched list | Unit close, only if items exist | Parked changes, accepted risks, open questions | Recorded as open in the project log |
| Project enablement | First time in a repository | Enable the automatic checks and pick the verification profile | The automatic gates stay inactive |

## 4. Cost and review load

| Item | Cost | Nature |
| --- | --- | --- |
| Commit gate | 5 to 15 ms per matching command | estimate; keep the script fast because hook timeouts fail open |
| Gate script | under 200 ms per run | estimate |
| Independent reviewer | one child agent, 5 to 15 s | measurement from real runs |
| Coder confirmations | no extra invocations; each coder's own turn | measurement |
| Human turns | 1.5 to 2 per unit | estimate; one for an unexpected amendment or a red gate, one at close |

## 5. Failure modes and guards

| Failure | Why | Guard |
| --- | --- | --- |
| The fence does not exist | hooks fail open; repository-local hooks may need an explicit trust grant | mount the fence where it is always active, make it a no-op when no register exists, and call it a drift fence |
| The gate cannot see inside the plan | semantic scope growth is invisible to a script | the unit-close diff review is the detector; state it as accepted risk |
| A provider stops answering | one model slug can fail for everyone at once | never pin a model in the rules or a role definition |
| A weak model loops on a denial | a deny without a path forward | every denial must be actionable, plus a recorded-reason bypass |
| Two documents drift | two records, two writers | the gate checks that both name the same active unit |
| Concurrent sessions collide | shared register files | one file per unit and per change request |

## 6. Adoption and rollback

1. Records and gate script only; no automation.
2. Automatic readout at session start.
3. Pilot: run the gate retroactively over the last few completed units in two
   repositories and measure what it would have caught.
4. Widen only where the measurement shows real drift rather than formalities.

Rollback is cheap by construction: the records are plain files, the gate is inert
when unmounted, and the method can be withdrawn without touching product code.
