---
name: wl-docs
description: >
  Use this skill for any Wolfram Language (WL/Mathematica) task requiring
  documentation lookup. WL has 6000+ functions with non-obvious naming, so
  key use cases include: discovering whether a function exists for a given
  purpose, verifying a named function actually does what it sounds like, and
  checking syntax, options, calling forms, return values, or related symbols.
  Applies when writing, debugging, or explaining WL code where a symbol's
  existence or exact behavior is uncertain.
---

# WL Docs

Local WL reference documentation, fetched from `reference.devel.wolfram.com`.

## Location and ref format

Docs directory: `/opt/wl-docs/`

Refs follow the Wolfram documentation URL path convention. Common prefixes:
- `ref/Plot` — symbol reference pages (the vast majority of useful content)
- `guide/CloudFunctionsAndDeployment` — topic overview pages
- `tutorial/GettingStartedOverview` — tech notes and tutorials
- `workflow/UseWolframLanguageDocumentation` — step-by-step workflow pages

A ref maps directly to a file: `/opt/wl-docs/{ref}.md`

## Searching for docs — freeform discovery

When you don't know the exact function name, use the documentation search index:

```bash
wolframscript -file /opt/wl-docs/search-docs.wls "query" [limit]
```

- `limit` is optional, defaults to 10
- Accepts natural language: `"find shortest path in graph"`, `"reverse a string"`, `"read csv file"`
- Returns JSON with `totalMatches`, and per result: `title`, `type`, `snippet`, `uri`
- `uri` is the ref to pass to `fetch-wl-docs.sh` or read from `/opt/wl-docs/{uri}.md`

Types in results: `Symbol`, `Guide`, `Tech Note`, `Workflow`, `ResourceFunction`, etc. Filter client-side if needed.

## Fetching docs

```bash
/opt/wl-docs/fetch-wl-docs.sh ref/Plot ref/Map guide/CreatingFormsAndApps
```

**Safe to call unconditionally.** The script is idempotent: if a ref is already
cached in `/opt/wl-docs/`, it returns immediately without hitting the network
(marked `[cached]` in the summary). Don't pre-check with `ls` or `test -f` —
just call it.

For each uncached ref, the script tries the exact ref first, falls back to a
corrected casing on 404 (e.g. `DataBin` → `Databin`), continues through any
failures, and prints a summary with file sizes and line counts. If a ref still
fails both attempts, double-check the exact symbol name — WL names don't always
follow obvious CamelCase conventions.

## Exploring a doc — recommended workflow

Don't read whole files into context. The docs are large; slice what you need.

**Step 1 — Scan the section map first**
```bash
/opt/wl-docs/bin/grep "^## \|^### " /opt/wl-docs/ref/FormFunction.md
```
One line tells you the full structure. Decide which sections are worth reading
before you read anything.

**Step 2 — Read the frontmatter for structured metadata**

The YAML block at the top of every file (between the two `---` lines) is the
most information-dense part:
- `summary` — one line covering all calling forms in prose
- `related_functions` — the See Also list; **use this to decide what to fetch next**
- `related_guides`, `related_tutorials`, `related_workflows` — broader context

```bash
FILE=/opt/wl-docs/ref/FormFunction.md

# Compact summary of the function
/opt/wl-docs/bin/awk '/^summary:/{sub(/^summary: "/,""); sub(/"$/,""); print; exit}' "$FILE"

# Related function names — the "fetch these next" list
/opt/wl-docs/bin/awk '/^related_functions:/,/^[a-z_]/' "$FILE" | /opt/wl-docs/bin/grep "    title:" | /opt/wl-docs/bin/sed 's/.*title: "//;s/"//'

# Search across all downloaded docs by keyword in summary
/opt/wl-docs/bin/grep -h "^summary:" /opt/wl-docs/ref/*.md | /opt/wl-docs/bin/grep -i "cloud deploy"
```

**Step 3 — Read the syntax block**

Plain text between the `# Title` line and the first `##`. The most compact form
of all calling signatures.

**Step 4 — Slice into specific sections as needed**

```bash
FILE=/opt/wl-docs/ref/FormFunction.md

# Syntax block (calling forms)
/opt/wl-docs/bin/awk '/^# /{found=1;next} found && /^## /{exit} found && NF' "$FILE"

# All wl code examples
/opt/wl-docs/bin/awk '/^```wl/{p=1;next} p&&/^```/{p=0;print "---";next} p' "$FILE"

# One subsection only (e.g. Basic Examples)
/opt/wl-docs/bin/awk '/^### Basic Examples/,/^### /' "$FILE"

# Details and Options
/opt/wl-docs/bin/awk '/^## Details/,/^## [^D]/' "$FILE"

# Possible Issues
/opt/wl-docs/bin/awk '/^### Possible Issues/,/^##/' "$FILE"

# Options table rows only
/opt/wl-docs/bin/awk '/^## Details/,/^## [^D]/' "$FILE" | /opt/wl-docs/bin/grep "^|"

# Which subsection does each code example live in?
/opt/wl-docs/bin/awk '/^### /{section=$0} /^```wl/{print section}' "$FILE"
```

These are starting points. The structure is regular enough that you can invent
whatever slice fits your context. See `references/doc-structure.md` for an
annotated sample of the full format.
