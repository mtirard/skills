# wl-docs

Claude Code skill for querying locally cached Wolfram Language reference documentation.

## Install

```bash
bash wl-docs/install.sh
```

This installs the skill to `~/.claude/skills/wl-docs`, deploys runtime files to `/opt/wl-docs/`, and patches `~/.claude/settings.json` with the required permissions. Safe to re-run.

## Usage

Fetch docs before starting a WL session:

```bash
/opt/wl-docs/fetch-wl-docs.sh ref/FormFunction ref/Databin guide/CreatingFormsAndApps
```

The skill is then triggered automatically when Claude needs WL documentation.
