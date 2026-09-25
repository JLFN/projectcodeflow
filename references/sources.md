# Sources of truth

This file lists every external source behind the method, what each one was read
for, and where the normative statements in this repository come from. Nothing in
the method is asserted from memory.

Access date for every source below: 2026-09-25.

## How the sources were read

The standards themselves are paywalled and are **not** reproduced here. Two kinds
of official material were used:

1. The ISO catalogue page for each standard (title, edition, publication date,
   lifecycle stage, and the abstract written by the committee).
2. The official ISO preview of each standard ("Read sample"), served by the
   ANSI webstore, whose first pages carry the table of contents. The clause
   titles quoted in this repository identify the practice areas the method
   aligns with; they are not a substitute for the standard.

Readers who need the normative text must obtain it from ISO or a national member
body. The clause titles are quoted only for identification, which is the
customary and permitted use.

## ISO standards used

| Standard | Title | Edition and status at the access date | Official page | What was read |
| --- | --- | --- | --- | --- |
| ISO 21502:2020 | Project, programme and portfolio management — Guidance on project management | Edition 1, published 2020-12, status Published, under systematic review (stage 90.60, close of review 2026-03-05); supersedes ISO 21500:2012 | https://www.iso.org/standard/74947.html | Catalogue page and abstract, plus the official preview's table of contents |
| ISO 10007:2017 | Quality management — Guidelines for configuration management | Edition 3, published 2017; at the access date the lifecycle showed stage 90.92 (to be revised) with work on a replacement under way | https://www.iso.org/standard/70400.html | Catalogue page and the official preview's table of contents |
| ISO 9001:2026 | Quality management systems — Requirements | Edition 6, published 2026-09 | https://www.iso.org/standard/9001 | Official preview's table of contents (clause list) |
| ISO 9001:2015 | Quality management systems — Requirements | Withdrawn; withdrawal recorded 2026-09-16 | https://www.iso.org/standard/62085.html | Catalogue page, to confirm the withdrawal and the replacement |
| ISO 9000:2026 | Quality management — Fundamentals and vocabulary | Current vocabulary edition of the family | https://www.iso.org/standard/9000 | Listed as a current edition on the official ISO 9000 family page |

Official family and committee pages used to confirm editions and current status:

- ISO 9000 family overview: https://www.iso.org/iso-9001-quality-management.html
- ISO/TC 258 (project, programme and portfolio management): https://committee.iso.org/sites/tc258/home/projects/published/iso-21502.html
- ISO/TC 176 (quality management): https://committee.iso.org/tc176sc2

Free official ISO material that covers the same ground as the paywalled clauses:

- Quality management principles: https://www.iso.org/publication/PUB100080.html
- ISO 9001 made simple: separating myths from facts: https://www.iso.org/publication/PUB100368.html
- How to use it: guidance for organizations using ISO 9001:2026: https://www.iso.org/publication/PUB100373.html

## Clause-level mapping

Each row is a statement in this repository and the practice area or clause it was
written against. The mapping is an alignment, not a certification claim: this
repository is not an ISO management system, and nothing here has been audited.

| Statement in this repository | Practice area or clause |
| --- | --- |
| The goal register, its part goals and the business-case style statement of why the work exists | ISO 21502:2020 project governance, including the business case, and scope management |
| Roles: the human as sponsor, the agent as project manager, the coders as work-package leaders, the verifier as assurance | ISO 21502:2020 project organisation and roles |
| Starting a unit only after the team mobilises and the plan is agreed | ISO 21502:2020 integrating practices: team mobilisation, governance and management approach, initial project planning |
| One unit, one branch, one baseline, one verification, then close | ISO 21502:2020 control of project performance, and the start and close of phases and work packages |
| The change register with AMEND / NEXT-UNIT / DEFER / REJECT and a recorded closing commit | ISO 21502:2020 change control (framework, identifying and assessing change requests, planning, implementing and closing) |
| The frozen baseline hash and the acceptance criteria as a configuration baseline | ISO 10007:2017 configuration baselines and configuration identification |
| Naming who may approve a baseline amendment, and only that person | ISO 10007:2017 responsibilities and authorities, including the dispositioning authority |
| The gate and the verification record | ISO 21502:2020 quality management, and ISO 9001:2026 control of changes and nonconformity handling |
| Git as the record of what changed, when, and under which unit | ISO 10007:2017 configuration status accounting |
| The alignment record and the project log | ISO 21502:2020 stakeholder engagement, communication and reporting |
| The five human decisions and the batched list | ISO 9001:2026 management review and monitoring, in the sense of a periodic decision point rather than a meeting format |
| The unit-close diff review as the detector for semantic scope growth | ISO 10007:2017 configuration audit |
| Planning change before doing it, and controlling change while doing it | ISO 9001:2026 planning of changes and control of changes |
| Treating a red gate as a recorded nonconformity rather than a retry | ISO 9001:2026 nonconformity and corrective action |

## What is deliberately not cited

- **The agent harness this method was first implemented against.** Its source is
  not public, so no file paths, line numbers or internal identifiers from it
  appear in this repository. The method is written to be self-contained: where a
  statement depends on a specific product capability, it is phrased as a
  capability the reader's harness may or may not have, and the limits section
  says what to do when it is missing.
- **Blogs, forums, vendor marketing pages and user-generated content.** None were
  used as a fact source. Where a fact about a standard was needed, the ISO
  catalogue page or the official preview was used.
- **The standards' normative text.** Obtain it from ISO or your national member
  body. This repository quotes clause titles for identification only.

## Maintenance

Standards move. When a standard named here is replaced or withdrawn, the edition
named in each claim must be updated in the same change, and this file's access
date must be refreshed. ISO 9001:2015 was withdrawn on 2026-09-16 and replaced by
ISO 9001:2026; a document that still cites the 2015 edition for a new project is
out of date, and this file exists so that error is visible rather than silent.
