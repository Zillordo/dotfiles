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
Description = Updating package lists for dotfiles tracking
When = PostTransaction
Exec = /bin/bash -c 'if [[ -n "${SUDO_USER:-}" ]] && [[ -x "/home/${SUDO_USER}/.local/bin/manage-package-lists" ]]; then "/home/${SUDO_USER}/.local/bin/manage-package-lists"; fi'
HOOK

echo "✅ Package tracking hooks setup complete!"
echo ""
echo "🔄 How it works:"
echo "   • AUTOMATIC: Detects added/removed packages after each pacman/yay operation"
echo "   • MANUAL: Run 'update-package-lists' to refresh manually"
echo "   • Shows desktop notifications with changes"
echo "   • Works with install, remove, and upgrade operations"
echo ""
echo "📁 Package lists will be maintained at:"
echo "   • ~/.config/install/packages-explicit.txt (explicitly installed)"
echo "   • ~/.config/install/packages-aur.txt (AUR packages)"
echo "   • ~/.config/install/packages-deps.txt (dependencies)"
echo "   • ~/.config/install/last-updated.txt (timestamp + changes)"
echo ""
echo "🎯 Test it:"
echo "   • Install/remove a package: yay -S neovim"
echo "   • Manual update: update-package-lists"
echo "   • Check changes: cat ~/.config/install/last-updated.txt"
