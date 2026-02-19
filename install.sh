#!/usr/bin/env bash
set -euo pipefail

# ccenv installer — copies ccenv to ~/.local/bin/ and sets up shell integration
# Requires Python 3.10+

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/ccenv" "$INSTALL_DIR/ccenv"
chmod +x "$INSTALL_DIR/ccenv"

printf 'Installed ccenv to %s/ccenv\n' "$INSTALL_DIR"

# Check if ~/.local/bin is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    printf '\nNote: %s is not in your PATH.\n' "$INSTALL_DIR"
    printf 'Add this to your shell profile (~/.bashrc or ~/.zshrc):\n\n'
    printf '  export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
fi

# Offer shell integration
printf '\nOptional: Add this Claude wrapper to your shell profile for automatic\n'
printf '--setting-sources when a profile is active:\n\n'
cat <<'SHELL'
  claude() {
    if [ -f ".claude/.profile" ]; then
      command claude --setting-sources project,local "$@"
    else
      command claude "$@"
    fi
  }
SHELL

printf '\nDone.\n'
