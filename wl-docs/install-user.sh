#!/usr/bin/env bash
# User-scope install: copies the skill to ~/.claude/skills and patches
# ~/.claude/settings.json. No sudo required. Run as the user who uses
# Claude Code (NOT a sudo/admin account).
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "error: install-user.sh must not run as root — it patches \$HOME/.claude." >&2
    echo "run it as the Claude Code user. Use install-system.sh (as root) for /opt/wl-docs." >&2
    exit 1
fi

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="wl-docs"
SKILLS_DEST="$HOME/.claude/skills/$SKILL_NAME"
SETTINGS="$HOME/.claude/settings.json"

echo "Installing skill to $SKILLS_DEST ..."
mkdir -p "$SKILLS_DEST"
cp "$SKILL_DIR/SKILL.md" "$SKILLS_DEST/SKILL.md"
rm -rf "$SKILLS_DEST/references"
cp -r "$SKILL_DIR/references" "$SKILLS_DEST/references"

echo "Patching $SETTINGS ..."
python3 - "$SETTINGS" <<'EOF'
import json, sys, os

path = sys.argv[1]
if os.path.exists(path):
    with open(path) as f:
        cfg = json.load(f)
else:
    cfg = {}

required = [
    "Bash(/opt/wl-docs/fetch-wl-docs.sh *)",
    "Bash(/opt/wl-docs/search-docs.wls *)",
    "Bash(wolframscript *)",
    "Bash(/opt/wl-docs/bin/grep *)",
    "Bash(/opt/wl-docs/bin/awk *)",
    "Bash(/opt/wl-docs/bin/sed *)",
    "Read(/opt/wl-docs/**)",
]

allow = cfg.setdefault("permissions", {}).setdefault("allow", [])
added = []
for entry in required:
    if entry not in allow:
        allow.append(entry)
        added.append(entry)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

if added:
    for e in added:
        print(f"  + {e}")
else:
    print("  (all entries already present)")
EOF

echo "Done. For runtime files under /opt/wl-docs, have your sudo account run:"
echo "  sudo $SKILL_DIR/install-system.sh"
