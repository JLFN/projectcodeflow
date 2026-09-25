# Project Code Flow

A project-management layer for agentic coding work, packaged as a skill.

The goal and its part goals are always understood and confirmed. Anything found
outside the planned unit becomes its own recorded change with its own branch, so
the current goal never stalls and never silently grows. A human is involved at
five named moments and nowhere else. A gate blocks delivery until the written
records agree with what the repository contains.

Nothing in this repository is tied to a specific model, vendor, or
orchestration framework. It needs git, a shell, and an agent harness that can run
a script and hold a file.

## Install as a skill

Copy the directory into your agent's skill path and keep the folder name:

```sh
cp -r projectcodeflow <your-skills-dir>/projectcodeflow
```

The skill is invoked as `/projectcodeflow`, with the sub-commands
`start`, `align`, `close` and `status`.

## Use without a skill system

1. Create the records: `.pm/GOALS.md`, `.pm/units/`, `.pm/cr/`, `.pm/meetings/`.
2. Copy `scripts/pm-gate.sh` into your test entry point and call it before any
   delivery step.
3. Follow `references/flow-en.md` or `references/flow-sv.md`.

## Contents

| Path | What |
| --- | --- |
| `SKILL.md` | The skill itself: the procedure, the records, the five human decisions, the change dispositions, the adoption stages and the limits |
| `references/flow-en.md` | The flow in detail, step by step, with the cost model |
| `references/flow-sv.md` | The same in Swedish, with the diagrams embedded |
| `references/sources.md` | Every external source behind the method, with the clause-level mapping to ISO 21502, ISO 10007 and ISO 9001:2026 |
| `references/roles-en.md` | How many agents the method needs, which role is new, the per-unit counts and the concurrency rules |
| `references/roles-sv.md` | The same in Swedish |
| `diagrams/` | Three diagrams as Mermaid source and rendered PNG |
| `presentation/board-sv.html` | A one-page board visual in Swedish, self-contained and offline-safe |
| `presentation/board-sv.png` | The same board visual rendered to an image for slides or print |
| `scripts/pm-gate.sh` | The delivery gate |
| `scripts/scaffold-unit.sh` | Creates a unit file and a change-request file from the templates |

## What it will not do

It will not turn a commit gate into a security boundary, it will not prove that
work stayed semantically inside its plan, and it will not let two units run in
parallel and still mean anything. The gate proves that the records exist and
agree with the repository; the unit-close diff review is what catches the rest.

## Verification

The gate and the scaffolding helper were exercised before this repository was
published, in a scratch repository, and every outcome that matters was observed:

| Situation | Observed |
| --- | --- |
| Register, unit contract, matching branch, alignment record and a dispositioned change request, with the frozen hash also in a commit trailer | `overall PASS`, exit 0 |
| The frozen hash is not anchored in any commit trailer | fails the anchor check, exit 1 |
| A word is silently added to the acceptance-criteria block | fails the baseline check, exit 1 (the scope-growth detector) |
| Two unit files are marked active at once | fails the single-unit check, exit 1 |
| The folder is not in the trust store passed with `--trust-file` | warns, or fails with `--strict-trust` |

## Adjustments after review

These were added because each one removes a way the method could quietly stop
working. Every one of them is in the scripts, not only in the prose.

1. **The frozen hash is anchored outside the record.** The gate now requires the
   same hash inside a commit trailer (`Baseline: <hash>`). A record that its own
   writer can rewrite cannot be the only place the frozen value lives.
2. **One unit in flight is enforced, not just recommended.** Two active unit files
   fail the gate. Parallel units make a baseline meaningless.
3. **The absence of the gate must be loud.** Repository-local automation can be
   skipped without a word when a folder is untrusted, which looks identical to a
   gate that passed. `--trust-file` makes the script say so, and `--strict-trust`
   turns it into a failure.
4. **The script is the authority.** Hook-based commit fences fail open, so the
   gate is written to run on its own at commit time and in CI; the fence is a
   convenience on top, never the guarantee.
5. **Records cannot be split across writers.** One file per unit and per change
   request, so two branches never append to the same document.

## Sammanfattning på svenska

Projektkodflöde är ett projektledningslager för agentiskt kodarbete. Målet och
delmålen skrivs ned, godkänns och följs upp. Allt som hittas utanför den planerade
enheten blir en egen registrerad ändring med egen gren, så att målet varken stannar
eller växer i tysthet. Människan är inblandad vid fem namngivna tillfällen och
ingen annanstans. En grind blockerar leverans tills de skrivna posterna stämmer med
vad repot innehåller. Metoden kräver git, ett skalskript och ett agentverktyg som
kan köra ett skript och hålla en fil — inget mer.

Flödet finns i detalj i `references/flow-sv.md`, med diagrammen inbäddade, och en
styrelsevänlig översikt i `presentation/board-sv.html`.

## License

Not yet chosen. Add a license before reusing this material outside your own
organisation.
