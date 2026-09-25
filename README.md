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
| `diagrams/` | Three diagrams as Mermaid source and rendered PNG |
| `presentation/board-sv.html` | A one-page board visual, self-contained and offline-safe |
| `scripts/pm-gate.sh` | The delivery gate |
| `scripts/scaffold-unit.sh` | Creates a unit file and a change-request file from the templates |

## What it will not do

It will not turn a commit gate into a security boundary, it will not prove that
work stayed semantically inside its plan, and it will not let two units run in
parallel and still mean anything. The gate proves that the records exist and
agree with the repository; the unit-close diff review is what catches the rest.

## Verification

The gate and the scaffolding helper were exercised before this repository was
published, in a scratch repository, and the two outcomes that matter were
observed:

- With the register, a unit contract, a matching branch, an alignment record and
  a dispositioned change request in place, the gate prints `overall PASS` and
  exits 0.
- With one word silently added to the acceptance-criteria block, the gate fails
  the baseline check and exits 1. That is the scope-growth detector working: the
  frozen hash is taken over exactly that block.

`scripts/scaffold-unit.sh` is what creates those records and computes the hash, so
the schema cannot drift by hand.

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
