---
name: living-docs
description: >-
  Architecture-first workflow with living documentation. Use this skill when
  starting or bootstrapping a new project, discussing or deciding architecture,
  making a technical decision (stack, database, framework, integration, pattern),
  writing or superseding an Architecture Decision Record (ADR / MADR), creating
  or updating the implementation plan, and whenever implementing code in a
  project that contains docs/ARCHITECTURE.md, docs/PLAN.md or docs/decisions/,
  so that documentation is updated in the same change as the code.
---

# Living Docs

Workflow: **decide together → document → implement → keep docs in sync**.
Documentation is part of the deliverable. A task is not done until the docs
match the code.

## Documentation layout (in the target project)

| File | Purpose | Tense |
|---|---|---|
| `AGENTS.md` | Always-on rules for any coding agent (managed block) | — |
| `CLAUDE.md` | Contains `@AGENTS.md` so Claude Code loads the same rules | — |
| `docs/ARCHITECTURE.md` | The system **as it is now** (official arc42 structure, C4 diagrams) | Present |
| `docs/PLAN.md` | Roadmap: phases, steps, status, links to ADRs | Future / status |
| `docs/decisions/NNNN-title.md` | One decision per file, MADR 4 format | Past (immutable) |
| `docs/decisions/README.md` | Index of all ADRs with status | — |

Rule of thumb: **planned** things go in `PLAN.md`; **built** things go in
`ARCHITECTURE.md`; **why** goes in an ADR.

## Mode 1 — Bootstrap a project

Use when the project has no `docs/ARCHITECTURE.md` yet, or the user asks to
"set up living docs".

1. Run from the project root:
   `bash <skill-dir>/scripts/bootstrap.sh [--vendor] [project-dir]`
   - Initializes git if needed, creates `AGENTS.md` (managed block, preserves
     existing content), `CLAUDE.md`, the `docs/` skeleton and the
     `commit-msg` hook in `.githooks/` (sets `core.hooksPath`).
   - `--vendor` also copies this skill into `.agents/skills/living-docs` and
     links it into `.claude/skills/` (for shared repos / cloud agents).
   - The script is idempotent: safe to re-run; it never overwrites existing docs.
2. Fill `docs/ARCHITECTURE.md` only with information the user has actually
   provided. Leave the other sections empty (keep their headings).

## ARCHITECTURE.md: arc42 + C4

- Structure is the **official arc42 template** (12 sections). Keep all section
  headings and their order, even when empty. Remove the `<placeholder>` text of
  a section when you fill it; replace sub-headings like `<Name black box 1>`
  with real names.
- Before writing a section, read its explanation in
  [references/arc42/arc42-template-EN-withhelp.md](references/arc42/SOURCE.md)
  (or https://docs.arc42.org).
- Diagrams use the **C4 model in Mermaid**; see
  [references/c4.md](references/c4.md) for the C4 → arc42 mapping and syntax.
- "Architecture Decisions" section: link to `decisions/README.md` and list the
  key ADRs (one line each). Do not duplicate ADR content.
- Describe only what is built. Planned items belong in `PLAN.md`.

## Mode 2 — Design and planning

Use while discussing requirements and architecture with the user.

1. Clarify requirements; record them in arc42 "Introduction and Goals" and
   "Architecture Constraints".
2. For each significant choice, present options with pros/cons and **let the
   user decide**. Do not record a decision the user has not confirmed
   (use status `proposed` if it is pending).
3. Write one ADR per decision (see "Writing ADRs").
4. Update arc42 "Solution Strategy" (short summary) and "Architecture
   Decisions" (links to the ADRs).
5. Write or update `PLAN.md`: small, verifiable steps, each linked to the
   ADRs it depends on.

## Mode 3 — Implementation

Before coding:
1. Read `docs/PLAN.md`, `docs/ARCHITECTURE.md` and the ADRs relevant to the task.
2. Implement **only** what is planned and decided. If the task requires
   deviating from an accepted ADR, or making a new significant choice,
   **stop and ask the user**; then write a new ADR before coding.

In the same change as the code:
3. Update `ARCHITECTURE.md` so it describes the code as it now is: arc42
   Building Block View, Runtime View, Deployment View, Cross-cutting Concepts,
   Risks and Technical Debts, Glossary; update the affected C4 diagrams.
4. Update `PLAN.md`: step status, and any new steps discovered.
5. Update the ADR index if ADRs changed.
6. Run the **Definition of Done** checklist below.

## Writing ADRs

- Create the file with the helper (picks the next number, fills the date):
  `bash <skill-dir>/scripts/new-adr.sh [--minimal] "Short title" [project-dir]`
- Templates (official MADR 4, verbatim) are in
  [references/madr/](references/madr/SOURCE.md). Remove guidance text and
  unused optional sections; keep headings in MADR order.
- **Full template** for major decisions: technology stack, database, framework,
  architecture style, external integrations, security/auth, data model
  foundations, anything costly to reverse.
- **Minimal template** for minor decisions: libraries, conventions, local
  patterns, easily reversible choices. Always keep the front-matter `status`
  and `date` (the helper adds them).
- `decision-makers`: the user's name and `AI agent` (with the agent/tool name)
  when applicable.
- Status lifecycle: `proposed` → `accepted` | `rejected`; later `deprecated` or
  `superseded by ADR-NNNN`.
- **Accepted ADRs are immutable.** Never rewrite their content. To change a
  decision: create a new ADR, then edit only the old ADR's `status` to
  `superseded by ADR-NNNN` and add a link in "More Information".
- Always fill "Considered Options" honestly — it prevents rejected options from
  being proposed again.
- Update `docs/decisions/README.md` (index table) on every ADR change.

## Definition of Done (docs)

- [ ] `ARCHITECTURE.md` reflects the current code (no stale components or
      descriptions of things not built yet), C4 diagrams included.
- [ ] `PLAN.md` step status updated; new follow-up steps added.
- [ ] Every new significant choice has an ADR, confirmed by the user.
- [ ] No accepted ADR was edited except for its status.
- [ ] ADR index updated.
- [ ] Docs changes are in the **same commit** as the code changes.

## Commit hook

The `commit-msg` hook warns when a commit changes non-doc files without
touching `docs/`, `AGENTS.md`, `CLAUDE.md` or `README.md`.
- If the warning appears, update the docs and amend, unless the change really
  has no doc impact (typos, formatting, dependency bumps): then add
  `[no-docs]` to the commit message.
- Strict mode (blocks the commit): `git config livingdocs.strict true`.
