#!/usr/bin/env bash
# System-scope install: copies runtime files to /opt/wl-docs. Must be run
# as root (e.g. `sudo ./install-system.sh`). Does NOT touch any user's
# $HOME — run install-user.sh separately as the Claude Code user.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "error: install-system.sh must run as root." >&2
    echo "  sudo $0" >&2
    exit 1
fi

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
OPT_DEST="/opt/wl-docs"

echo "Installing runtime files to $OPT_DEST ..."
mkdir -p "$OPT_DEST/bin"

install -m 0755 "$SKILL_DIR/fetch-wl-docs.sh" "$OPT_DEST/fetch-wl-docs.sh"
install -m 0755 "$SKILL_DIR/search-docs.wls" "$OPT_DEST/search-docs.wls"

for cmd in grep awk sed; do
    install -m 0755 "$SKILL_DIR/bin/$cmd" "$OPT_DEST/bin/$cmd"
done

# usage.log must be writable by whatever user runs the wrappers.
# Create it world-writable (sticky is not meaningful for a regular file).
touch "$OPT_DEST/usage.log"
chmod 0666 "$OPT_DEST/usage.log"

echo "Done."
