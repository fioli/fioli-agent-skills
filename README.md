# fioli-agent-skills

A collection of personal, **agent-agnostic skills** following the open
[Agent Skills](https://agentskills.io) standard (`SKILL.md`).
Each skill works with Antigravity, Claude Code, Codex  and any other agent that
reads `SKILL.md` skills and `AGENTS.md`.

Each top-level folder containing a `SKILL.md` is one independent skill. You can
install **only the skills you need**.

## Skills collection

| Skill | Purpose |
|---|---|
| [living-docs](README-living-docs.md) | Keep project documentation up to date with every code change |

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
- Human documentation and design decisions for each skill live in
  `README-<skill>.md` at the repo root (keeping `<skill>/` strictly for
  agent-facing files; no ADRs for the skills themselves).
- Third-party material (templates, standards) is copied **verbatim** with a
  `SOURCE.md` stating origin, version and license.
