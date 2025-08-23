#!/bin/bash
set -e

# Initialize Atuin for Nushell if installed and not yet initialized
if ! command -v atuin >/dev/null 2>&1; then
  echo "Atuin not installed; skipping initialization."
  exit 0
fi

ATUIN_DIR="$HOME/.local/share/atuin"
INIT_FILE="$ATUIN_DIR/init.nu"

mkdir -p "$ATUIN_DIR"

if [ ! -s "$INIT_FILE" ]; then
  echo "Initializing Atuin for Nushell..."
  atuin init nu >"$INIT_FILE"
  echo "Atuin init file written to $INIT_FILE"
else
  echo "Atuin already initialized; skipping."
fi
