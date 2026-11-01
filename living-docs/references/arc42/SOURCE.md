# arc42 template — source

Verbatim copies of the official arc42 template (GitHub-flavoured Markdown).
Do not edit them here; update them from upstream instead.

- Project: arc42 — https://arc42.org, https://github.com/arc42/arc42-template
- Release: `2026.10.19` (template version 9.1-EN, October 2026)
- Assets: `arc42-template-EN-plain-gitHubMarkdown.zip`,
  `arc42-template-EN-withhelp-gitHubMarkdown.zip`
- License: CC BY-SA 4.0 — © Dr. Peter Hruschka, Dr. Gernot Starke and
  contributors (https://arc42.org/license)

| File | Use for |
|---|---|
| `arc42-template-EN-plain.md` | Pristine plain template (source of `templates/ARCHITECTURE.md`) |
| `arc42-template-EN-withhelp.md` (+ `images/`) | **Reference for agents:** explains what belongs in each section. Read the relevant section before writing it. Online docs: https://docs.arc42.org |

`templates/ARCHITECTURE.md` = custom header (living-doc note, attribution,
change notice) + the plain template body from "Introduction and Goals" on,
unchanged.

## How to update

```bash
TAG=<release-tag>
for v in plain withhelp; do
  curl -sfLO "https://github.com/arc42/arc42-template/releases/download/$TAG/arc42-template-EN-$v-gitHubMarkdown.zip"
done
```

Then refresh the files, rebuild `templates/ARCHITECTURE.md` and update the
release/version above.
