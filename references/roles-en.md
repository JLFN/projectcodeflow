# Roles and agents — how many you actually need

Short answer: **the method needs one agent.** Everything else is optional shape
around it. If your harness can spawn children, the recommended shape is three
roles, and exactly one of them is new compared to a plain agent-with-a-verifier
setup.

## The roles

| Role | What it is | New? | How many per unit | Model |
| --- | --- | --- | --- | --- |
| Project manager | The working session's own agent, with a named role and the register in front of it | No — it is the session agent | 1 | Your strongest capable model, resolved per project |
| Coder | A child agent per work package | No — ordinary subagents | 1 to 3 | Cheaper than the manager, resolved per project |
| Independent reviewer | A read-only child that restates the contract and challenges it before work starts | **Yes** | Exactly 1 per unit, never one per part goal | A different slug from the coder where possible; otherwise the same slug in a different role |
| Verifier | The independent verification run that already exists in most setups | No | 1 run per unit | Chosen per project, as the verification model already is |

The human is not an agent. The gate, the records and the log rotation are not
agents either: they are a shell script and some files.

## Configuring it

1. **Role definition files are optional.** One file per role buys you a per-role
   model, permission mode, timeout and instruction text. Without them the method
   still works: the session agent is the manager and the harness's normal child
   mechanism supplies the coders.
2. **One verification model per project.** If you already pick a verification
   model per project, keep doing exactly that.
3. **One enablement decision per repository.** Whatever your harness requires
   before folder-local automation may run, decide it once, and make the gate
   report when it is missing — an inactive gate must not look like a passing one.

## Counts per unit

| Path | Invocations | Human turns mid-unit |
| --- | --- | --- |
| Short path, no blocking ambiguity: manager + 1-3 coders + verification | 3 to 5 | 0 |
| Full path, alignment needed: the same plus 1 reviewer | 4 to 6 | 0, plus 1 at close if items were parked |

## Concurrency and nesting

- **Assume a flat tree.** Many harnesses allow only one level of nesting, so the
  manager cannot have a coder that spawns its own reviewer. Every role is a child
  of the manager.
- **Children usually have no shared memory and no channel to each other.** They do
  not persist between units, so the alignment record is their only shared state.
  Write it to a file; never rely on a conversation.
- **Parallel coders are fine if the models are hosted.** If any role runs on a
  local model, serialize: one local inference thread at a time, so no two local
  roles in flight.
- **If your harness has no subagents at all**, the roles collapse into sequential
  turns of one agent: restate, work, then verify, each as its own step, with the
  same records written to disk. The method loses parallelism, not correctness.
- **Give the reviewer read-only access.** A reviewer that can edit is not a
  reviewer. If your harness lets a child ask the user a question, you may enable it
  for coders; keep it off for the reviewer so nothing interrupts an alignment.

## Choosing the models

- **Never pin a model in the rules or in a role definition.** A provider can fail
  for everyone at once, and a pinned slug then takes the whole method down with it.
  Resolve per project at runtime.
- **Independence comes from the role, not from the slug.** A reviewer that did not
  write the code is independent even on the same model. Prefer a different model
  where you have one; do not buy a second provider just for this.
- **Cost order that works in practice:** strongest model on the manager, cheapest
  capable model on the coders, a mid-tier model on the reviewer and the verifier.

## When to drop the reviewer

Run the pilot first. If the reviewer repeatedly raises the same ambiguity the
manager already resolved, remove it and keep the five decision points and the gate.
If it catches real mismatches between the written contract and the code, keep it and
give it its own model. One reviewer per unit is the ceiling either way.
