# WL Doc Structure — Annotated Sample

Annotated extract from `ref/FormFunction.md`. Every ref doc follows this shape.

---

## 1. YAML Frontmatter (between the `---` delimiters)

```
---
title: "FormFunction"
language: "en"
type: "Symbol"                         ← always "Symbol" for ref/ docs

summary: "FormFunction[formspec, func] represents..."
                                       ← SINGLE LINE. Full prose summary of all
                                          calling forms. Dense but parseable.

keywords:                              ← list of plain strings
- form
- web app
...

related_guides:                        ← structured list with title + link
  -
    title: "Custom Interface Construction"
    link: "https://reference.wolfram.com/language/guide/..."
  ...

related_functions:                     ← same structure — the See Also list
  -
    title: "FormObject"
    link: "https://reference.wolfram.com/language/ref/FormObject"
  ...

related_tutorials:                     ← same structure
  ...

related_workflows:                     ← same structure
  ...
---
```

The frontmatter is the richest, most compact part of the doc. Key fields:

| Field | What it gives you |
|---|---|
| `summary` | All calling forms in one prose line |
| `related_functions` | The See Also list — use to discover what to fetch next |
| `related_guides` | Broader topic guides |
| `related_tutorials` | Tech note pages |
| `related_workflows` | Step-by-step workflow pages |
| `keywords` | Plain-text tags — useful for cross-doc search |

Cross-doc keyword search (across all downloaded docs):
```bash
# Which docs mention "cloud deploy" in their summary?
grep -rl "cloud deploy" /opt/wl-docs/ref/ | \
  xargs -I{} awk '/^summary:/{print FILENAME": "$0; exit}' {}

# Which docs have "histogram" as a keyword?
grep -l "histogram" /opt/wl-docs/ref/*.md

# Dump all summaries for quick scanning
grep "^summary:" /opt/wl-docs/ref/*.md | sed 's|.*/||;s|\.md:summary:| — |'
```

---

## 2. Title line

```
# FormFunction  Listing of Field Types »
```

Single `#` h1. Sometimes has a subtitle after extra whitespace.

---

## 3. Syntax block (between `# Title` and first `##`)

Plain text, NOT in a code block. Each calling form on its own line, with
description on the next line. Variants are tab-indented.

```
FormFunction[formspec,func]
represents an active form that, when submitted, applies func to the values...
	FormFunction[{"name"->type,...},func]
represents an active form with fields named...
	FormFunction[formspec,func,fmt]
specifies that in the cloud, the result from applying func...
```

---

## 4. Body sections — all delimited by `##` headers

```
## Details and Options          ← bullet points, prose, and markdown tables
## Examples (49)                ← the number in parens is total example count
### Basic Examples (4)          ← subsection with count
#### Interpreter Specifications (6)   ← sub-subsection (4th level)
### Scope (25)
### Options (6)
### Applications (2)
### Properties & Relations (8)
### Possible Issues (1)
### Neat Examples (3)
## See Also                     ← list of * [`Symbol`](url) entries
## Tech Notes                   ← links to tutorial pages
## Related Guides               ← links
## Related Workflows            ← links
## Related Links                ← links
## History                      ← version introduced/updated info
```

Section depth:
- `##` = top-level section (Details, Examples, See Also, ...)
- `###` = subsection within Examples (Basic Examples, Scope, ...)
- `####` = sub-subsection (option name, topic grouping)

---

## 5. Code blocks

All WL code examples use ` ```wl ` fenced blocks.

````
```wl
In[1]:= form = FormFunction[{"first" -> "String", "second" -> "Number"}, f]

Out[1]=
FormFunction[FormObject[Association[...]], f]
```
````

Format: `In[N]:= expr` on its own line, then `Out[N]=` followed by result.
Multi-line inputs use indentation. Sometimes output is omitted if it's graphical
(`<image>` placeholder appears instead).

---

## 6. See Also section

```
## See Also

* [`FormObject`](https://reference.wolfram.com/language/ref/FormObject)
* [`APIFunction`](https://reference.wolfram.com/language/ref/APIFunction)
...
```

Markdown links in `* [backtick-name](url)` format.

---

## Key awk anchors

| What you want to find | Pattern to match |
|---|---|
| Start of frontmatter | `^---$` (first occurrence) |
| End of frontmatter | `^---$` (second occurrence) |
| Start of syntax block | `^# ` |
| Any top-level section | `^## ` |
| Any subsection | `^### ` |
| Any sub-subsection | `^#### ` |
| WL code block start | `^` ``` `wl$` |
| WL code block end | `^` ``` `$` |
| See Also entry | `^\* \[` |
