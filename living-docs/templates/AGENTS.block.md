<!-- living-docs:start — managed by the living-docs skill; edit outside this block -->
## Working agreement: architecture-first, living documentation

This project follows the **living-docs** workflow. These rules apply to every
coding agent (Claude Code, Codex, Antigravity, …) and to humans.

1. **Read before coding.** Before implementing anything, read
   `docs/PLAN.md`, `docs/ARCHITECTURE.md` and the relevant ADRs in
   `docs/decisions/`.
2. **Implement only what is decided.** If a task requires a new significant
   technical choice or deviates from an accepted ADR, stop and ask the user.
   After the user decides, record it as a new ADR before coding.
3. **Docs in the same change.** Every code change updates the docs in the same
   commit: `ARCHITECTURE.md` (current state), `PLAN.md` (status), ADRs and
   their index. A task is not done until the docs match the code.
4. **ADRs use MADR 4** (full template for major decisions, minimal for minor
   ones). Accepted ADRs are immutable: supersede them, never rewrite them.
5. **Documentation language: English.**
6. For procedures, templates and helper scripts use the **`living-docs`**
   skill. If the skill is not available, follow the rules above and the
   existing files in `docs/` as examples.

A `commit-msg` hook warns when code changes without doc changes. Use
`[no-docs]` in the commit message only for changes with no doc impact.
<!-- living-docs:end -->
