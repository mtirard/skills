# wl-docs

Claude Code skill for querying locally cached Wolfram Language reference documentation.

## Install

**Skill** — copy the skill directory into Claude Code's skills folder:

```bash
cp -r wl-docs ~/.claude/skills/wl-docs
```

**Fetch script** — install and make executable:

```bash
sudo mkdir -p /opt/wl-docs
sudo cp wl-docs/fetch-wl-docs.sh /opt/wl-docs/fetch-wl-docs.sh
sudo chmod +x /opt/wl-docs/fetch-wl-docs.sh
```

## Usage

Fetch docs before starting a WL session:

```bash
/opt/wl-docs/fetch-wl-docs.sh ref/FormFunction ref/Databin guide/CreatingFormsAndApps
```

The skill is then triggered automatically when Claude needs WL documentation.
