# MADR templates — source

Verbatim copies of the official MADR (Markdown Architectural Decision Records)
templates. Do not edit them here; update them from upstream instead.

- Project: MADR — https://adr.github.io/madr/, https://github.com/adr/madr
- Release: `4.0.0` (September 2024)
- Upstream path: `template/adr-template.md`, `template/adr-template-minimal.md`
- License: CC0-1.0 OR MIT (https://github.com/adr/madr#license)

| File | Use for |
|---|---|
| `adr-template.md` | Full ADR template for major architectural decisions (default in `scripts/new-adr.sh`) |
| `adr-template-minimal.md` | Minimal ADR template for minor/bounded decisions (`scripts/new-adr.sh --minimal`) |

## How to update

```bash
TAG=<release-tag>   # e.g. 4.0.0
for f in adr-template.md adr-template-minimal.md; do
  curl -sfL "https://raw.githubusercontent.com/adr/madr/$TAG/template/$f" -o "$f"
done
```

Then verify `scripts/new-adr.sh` still matches the front matter and `# {short title...}`
heading, and update the release version above.
