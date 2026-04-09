#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="wl-docs"
SKILLS_DEST="$HOME/.claude/skills/$SKILL_NAME"
OPT_DEST="/opt/wl-docs"
SETTINGS="$HOME/.claude/settings.json"

# ── Skill files → ~/.claude/skills/wl-docs ────────────────────────────────────
echo "Installing skill to $SKILLS_DEST ..."
mkdir -p "$SKILLS_DEST"
cp "$SKILL_DIR/SKILL.md" "$SKILLS_DEST/SKILL.md"
cp -r "$SKILL_DIR/references" "$SKILLS_DEST/references"

# ── Runtime files → /opt/wl-docs ──────────────────────────────────────────────
echo "Installing runtime files to $OPT_DEST ..."
sudo mkdir -p "$OPT_DEST/bin"

sudo cp "$SKILL_DIR/fetch-wl-docs.sh" "$OPT_DEST/fetch-wl-docs.sh"
sudo chmod +x "$OPT_DEST/fetch-wl-docs.sh"

sudo cp "$SKILL_DIR/search-docs.wls" "$OPT_DEST/search-docs.wls"
sudo chmod +x "$OPT_DEST/search-docs.wls"

for cmd in grep awk sed; do
    sudo cp "$SKILL_DIR/bin/$cmd" "$OPT_DEST/bin/$cmd"
    sudo chmod +x "$OPT_DEST/bin/$cmd"
done

# ── settings.json permissions ──────────────────────────────────────────────────
echo "Patching $SETTINGS ..."
python3 - "$SETTINGS" <<'EOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)

required = [
    "Bash(/opt/wl-docs/fetch-wl-docs.sh:*)",
    "Bash(/opt/wl-docs/search-docs.wls:*)",
    "Bash(wolframscript*)",
    "Bash(/opt/wl-docs/bin/grep:*)",
    "Bash(/opt/wl-docs/bin/awk:*)",
    "Bash(/opt/wl-docs/bin/sed:*)",
    "Read(/opt/wl-docs/**)",
]

allow = cfg.setdefault("permissions", {}).setdefault("allow", [])
added = []
for entry in required:
    if entry not in allow:
        allow.append(entry)
        added.append(entry)

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

if added:
    for e in added:
        print(f"  + {e}")
else:
    print("  (all entries already present)")
EOF

echo "Done."
