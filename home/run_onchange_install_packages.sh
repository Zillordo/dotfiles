#!/bin/bash

set -e # Exit on any error

echo "Installing packages with yay..."

# Package list
packages=(
  "zoxide"
  "zen-browser-bin"
  "tmux"
  "nushell"
  "starship"
  "ghostty"
  "slack-desktop-wayland"
  "obsidian-bin"
  "spotify"
  "tmux-plugin-manager"
  "nodejs"
  "direnv"
)

# Check if yay is installed
if ! command -v yay &>/dev/null; then
  echo "Error: yay is not installed or not in PATH"
  exit 1
fi

# Install all packages at once (more efficient)
echo "Installing: ${packages[*]}"
yay -S --needed --noconfirm "${packages[@]}"

echo "✅ Package installation completed!"

# Optional: Show installed versions
echo -e "\n📦 Installed package versions:"
for package in "${packages[@]}"; do
  if yay -Qi "$package" &>/dev/null; then
    version=$(yay -Qi "$package" | grep '^Version' | awk '{print $3}')
    echo "  $package: $version"
  else
    echo "  $package: ❌ Not found"
  fi
done
