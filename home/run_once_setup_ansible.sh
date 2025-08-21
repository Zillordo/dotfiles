#!/usr/bin/env nu

echo "Installing: ansible"
yay -S --needed --noconfirm "ansible"

mkdir ~/.local/share/atuin/
atuin init nu | save ~/.local/share/atuin/init.nu
