#!/bin/sh

set -e # -e: exit on error

# Prefer installing with yay if available
if [ ! "$(command -v chezmoi)" ]; then
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm chezmoi
    chezmoi=chezmoi
  else
    bin_dir="$HOME/.local/bin"
    chezmoi="$bin_dir/chezmoi"
    if [ "$(command -v curl)" ]; then
      sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
    elif [ "$(command -v wget)" ]; then
      sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
    else
      echo "To install chezmoi, you must have curl or wget installed." >&2
      exit 1
    fi
  fi
else
  chezmoi=chezmoi
fi

# Ensure age is available for decrypting identity
if ! command -v age >/dev/null 2>&1; then
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm age
  else
    echo "Warning: age is not installed; cannot decrypt age identity if needed." >&2
  fi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Initialize chezmoi first (creates ~/.config/chezmoi) but do not apply yet
"$chezmoi" init "--source=$script_dir"

# Decrypt repo-stored encrypted age identity into ~/.config/chezmoi/key.txt
src_enc="$script_dir/private_key.txt.age"
dest_key="$HOME/.config/chezmoi/key.txt"
if [ -f "$src_enc" ]; then
  if [ -f "$dest_key" ]; then
    echo "Age identity already exists at $dest_key; skipping decrypt."
  else
    if command -v age >/dev/null 2>&1; then
      echo "Decrypting age identity from $src_enc to $dest_key (you may be prompted for passphrase)"
      age -d -o "$dest_key" "$src_enc"
      chmod 600 "$dest_key"
    else
      echo "Warning: age not found; cannot decrypt $src_enc" >&2
    fi
  fi
fi

# Now apply dotfiles
"$chezmoi" apply
