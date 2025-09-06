#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Setting up automatic package tracking with pacman hooks..."

# Check if yay is available
if ! command -v yay >/dev/null 2>&1; then
  echo "⚠️  Warning: yay not found. The script will use pacman instead."
  echo "   Install yay for better AUR package detection."
fi

# Create the pacman hooks
sudo mkdir -p /etc/pacman.d/hooks

# Post-transaction hook (for install/upgrade/remove)
sudo tee /etc/pacman.d/hooks/95-update-package-lists.hook >/dev/null <<'HOOK'
[Trigger]
Operation = Install
Operation = Remove
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Updating package.yaml lists for tracking
When = PostTransaction
Exec = /bin/bash -c 'if [[ -n "${SUDO_USER:-}" ]] && [[ -x "/home/${SUDO_USER}/.local/bin/packages_hook" ]]; then "/home/${SUDO_USER}/.local/bin/packages_hook"; fi'
HOOK

echo "✅ Package tracking hooks setup complete!"
