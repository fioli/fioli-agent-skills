# fioli-agent-skills

A collection of personal, **agent-agnostic skills** following the open
[Agent Skills](https://agentskills.io) standard (`SKILL.md`).
Each skill works with Claude Code, Codex, Antigravity and any other agent that
reads `SKILL.md` skills and `AGENTS.md`.

Each top-level folder containing a `SKILL.md` is one independent skill. You can
install **only the skills you need**.

## Skills

| Skill | Purpose |
|---|---|
| [living-docs](#living-docs) | Architecture-first workflow with living documentation (MADR 4 ADRs, arc42 + C4, docs kept in sync with code) |

## Installation

Requirements: `bash`, `git`, a Unix-like system (Linux, macOS, WSL).

```bash
git clone <this-repo-url> ~/DEV/fioli-agent-skills
cd ~/DEV/fioli-agent-skills

./install.sh --list                   # available skills and install status
./install.sh living-docs              # install one skill
./install.sh living-docs other-skill  # install several skills
./install.sh --all                    # install every skill
./install.sh --uninstall living-docs  # remove one skill
./install.sh --uninstall --all        # remove every skill of this repo
```

Skills are installed **globally** (available in every project) via symlinks,
so editing a skill in this repo is immediately visible to every agent:

```
~/.agents/skills/<skill>                  -> this repo   (hub, Codex)
~/.claude/skills/<skill>                  -> hub         (Claude Code)
~/.gemini/antigravity-cli/skills/<skill>  -> hub         (Antigravity CLI)
~/.codex/skills/<skill>                   -> hub         (only if ~/.codex exists)
```

The installer never overwrites an existing non-symlink folder with the same
name; it reports `SKIP` instead.

## Repository conventions

- One folder per skill, named like the skill's `name` field.
- Each skill is self-contained: `SKILL.md` + optional `scripts/`, `templates/`,
  `references/`. No dependencies between skills.
- Third-party material (templates, standards) is copied **verbatim** with a
  `SOURCE.md` stating origin, version and license.
- Design decisions are recorded in this README, in the section of the skill
  they belong to (no ADRs for the skills themselves).

---

## living-docs

Architecture-first workflow: **decide together → document → implement → keep
docs in sync**. Documentation is part of the deliverable: a task is not done
until the docs match the code.

Skill instructions: [living-docs/SKILL.md](living-docs/SKILL.md)

### How to use

| Step | What | How often |
|---|---|---|
| 1 | **Install** the skill | Once per machine |
| 2 | **Bootstrap** the project | Once in **every project** where you want to use it |
| 3 | **Work with your agent** | Daily workflow (design, ADRs, implementation) |

#### Step 1 — Install the skill (once per machine)

```bash
./install.sh living-docs
```

This makes the skill available to every coding agent on your machine (see
[Installation](#installation)). Re-running it is safe.

#### Step 2 — Bootstrap each project (required before using the skill)

Installing the skill is not enough: each project must be **initialized** before
the workflow can be used in it. Bootstrap creates the files the workflow relies
on — most importantly `AGENTS.md`, which every agent reads at the start of each
session and which tells it to follow the workflow and keep the docs in sync.
Without this step, agents working in the project will not apply the workflow.

From the project root, ask your agent *"bootstrap living docs in this
project"*, or run:

```bash
bash ~/.agents/skills/living-docs/scripts/bootstrap.sh [--vendor] [project-dir]
```

`project-dir` defaults to the current directory. Bootstrap runs `git init` if
the project is not a git repository yet, then creates:

| File | Purpose |
|---|---|
| `AGENTS.md` | Always-on rules for every agent (managed block; other content preserved) |
| `CLAUDE.md` | `@AGENTS.md` import, so Claude Code loads the same rules |
| `docs/ARCHITECTURE.md` | The system as it is now — official arc42 template, C4 diagrams in Mermaid |
| `docs/PLAN.md` | Roadmap with step status, linked to ADRs |
| `docs/decisions/` | ADRs in MADR 4 format + `README.md` index |
| `.githooks/commit-msg` | Warns when code changes without doc changes |

It also sets `git config core.hooksPath .githooks` to enable the hook.

- `--vendor` also copies the skill into the project (`.agents/skills/`, linked
  from `.claude/skills/`), for shared repos or cloud agents that cannot see
  your home directory.
- Bootstrap is idempotent: re-running it never overwrites existing docs; it
  only refreshes the managed block in `AGENTS.md` and the hook.
- Bootstrap does not commit: review and commit the generated files yourself.
- `core.hooksPath` is a local git setting and is not versioned: after cloning
  a bootstrapped project (on another machine or by another person), run
  `git config core.hooksPath .githooks` to enable the hook again.

#### Step 3 — Work with your coding agent

Chat normally with your coding agent (Claude Code, Antigravity, Codex, …).
Because `AGENTS.md` is loaded automatically at every session, the agent
already knows the rules:

1. **Design and planning:** discuss requirements and architecture with the
   agent. It proposes options with pros/cons, records every confirmed choice
   as a MADR 4 ADR in `docs/decisions/`, and fills `docs/ARCHITECTURE.md` and
   `docs/PLAN.md`.
2. **Implementation:** ask the agent to implement steps from the plan. Before
   coding it reads `PLAN.md`, `ARCHITECTURE.md` and the relevant ADRs; it
   updates `docs/` in the **same commit** as the code, and at the end of every
   task reports which documentation files were updated (or why none needed
   updating).
3. **Changing a decision:** if a task requires deviating from an accepted ADR
   or making a new significant choice, the agent stops, asks you, and writes a
   new ADR superseding the old one before coding.

> Tip: you do not have to mention the skill explicitly, thanks to `AGENTS.md`,
> though saying *"use living-docs to…"* at the start of a design or planning
> session guarantees the full templates and checklists are loaded right away.

### Helpers

```bash
# New ADR with the next number (full template; --minimal for minor decisions)
bash ~/.agents/skills/living-docs/scripts/new-adr.sh [--minimal] "Short title" [project-dir]

# Commit hook options (per project)
git config livingdocs.strict true    # block instead of warn
git config livingdocs.enabled false  # disable
# one-off bypass: put [no-docs] in the commit message
```

### Design decisions

- **Rules in `AGENTS.md`, procedure in the skill.** Skills are loaded on demand,
  so the always-on rule ("update docs with the code") lives in each project's
  `AGENTS.md`; the skill holds the how-to, templates and scripts.
- **MADR 4** for ADRs: full template for major decisions, minimal for minor
  ones. Templates verbatim from upstream
  ([SOURCE.md](living-docs/references/madr/SOURCE.md)).
- **Official arc42 template** (v9.1, section structure unchanged) for
  `ARCHITECTURE.md`, with **C4 model diagrams in Mermaid**
  ([arc42 SOURCE.md](living-docs/references/arc42/SOURCE.md),
  [c4.md](living-docs/references/c4.md)). Replaces an earlier custom
  "arc42-lite" structure, which was not a standard.
- **Documentation language: English.**
- **`commit-msg` git hook** (agent-independent) as a safety net, warn-only by
  default. `commit-msg` rather than `pre-commit` because it can read the
  message and honour `[no-docs]`.
