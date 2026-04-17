# wl-docs

Claude Code skill for querying locally cached Wolfram Language reference documentation.

## Install

Two scripts, because the skill lives in `~/.claude` (user scope) and its runtime files live in `/opt/wl-docs` (system scope). Both are idempotent — safe to re-run.

1. As your normal (Claude Code) user:
   ```bash
   bash wl-docs/install-user.sh
   ```
   Copies the skill to `~/.claude/skills/wl-docs` and patches `~/.claude/settings.json`.

2. As root (or via a sudo-capable account — can be a different account pointing at the same clone):
   ```bash
   sudo bash wl-docs/install-system.sh
   ```
   Copies runtime files to `/opt/wl-docs/`. Does not touch any user's `$HOME`.

## Usage

Fetch docs before starting a WL session:

```bash
/opt/wl-docs/fetch-wl-docs.sh ref/FormFunction ref/Databin guide/CreatingFormsAndApps
```

The skill is then triggered automatically when Claude needs WL documentation.
