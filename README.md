# agent-skills

Personal, agent-agnostic skills following the open
[Agent Skills](https://agentskills.io) standard (`SKILL.md`).
Works with Claude Code, Codex, Antigravity and any agent that reads
`SKILL.md` skills and `AGENTS.md`.

## Skills

| Skill | Purpose |
|---|---|
| [living-docs](living-docs/SKILL.md) | Architecture-first workflow: decide together, record decisions as MADR 4 ADRs, keep `ARCHITECTURE.md` / `PLAN.md` in sync with the code |

## Install (global, all agents)

```bash
./install.sh            # create symlinks
./install.sh --uninstall
```

Symlink layout (edit here once, every agent sees the change):

```
~/.agents/skills/<skill>                  -> this repo   (hub, Codex)
~/.claude/skills/<skill>                  -> hub         (Claude Code)
~/.gemini/antigravity-cli/skills/<skill>  -> hub         (Antigravity CLI)
~/.codex/skills/<skill>                   -> hub         (if ~/.codex exists)
```

## Use living-docs in a new project

Ask your agent: *"bootstrap living docs in this project"*, or run:

```bash
bash ~/.agents/skills/living-docs/scripts/bootstrap.sh [--vendor] [project-dir]
```

This creates `AGENTS.md` (managed block), `CLAUDE.md` (`@AGENTS.md`),
`docs/ARCHITECTURE.md`, `docs/PLAN.md`, `docs/decisions/` and a `commit-msg`
hook that warns when code changes without doc changes.

## Design decisions

- **Rules in `AGENTS.md`, procedure in the skill.** Skills are loaded on demand,
  so the always-on rule ("update docs with the code") lives in each project's
  `AGENTS.md`; the skill holds the how-to, templates and scripts.
- **MADR 4** for ADRs (full + minimal templates, verbatim from upstream; see
  [SOURCE.md](living-docs/references/madr/SOURCE.md)).
- **Official arc42 template** (v9.1, verbatim section structure) for
  `ARCHITECTURE.md`, with **C4 model diagrams in Mermaid** (see
  [arc42 SOURCE.md](living-docs/references/arc42/SOURCE.md) and
  [c4.md](living-docs/references/c4.md)). Replaces an earlier custom
  "arc42-lite" structure, which was not a standard.
- Decisions about this repo are recorded here in the README (no ADRs for the
  skill itself).
- **Git hook** (agent-independent) as a safety net, warn-only by default
  (`git config livingdocs.strict true` to block).
