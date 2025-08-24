#!/usr/bin/env bash
set -euo pipefail

# FZF args inspired by user's example
fzf_args=(
  --multi
  --cycle
  --reverse
  --prompt 'mise plugins> '
  --preview 'printf "Plugin: %s\nRepo: %s\n" {1} {2}'
  --preview-window 'down:65%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
)

if ! command -v mise >/dev/null 2>&1; then
  echo "mise not found in PATH" >&2
  exit 1
fi

# List all available plugins as "name repo"
mapfile -t selections < <(mise registry | fzf "${fzf_args[@]}")

if [[ ${#selections[@]} -eq 0 ]]; then
  exit 0
fi

for line in "${selections[@]}"; do
  name=$(awk '{print $1}' <<<"$line")
  repo=$(awk '{print $2}' <<<"$line")
  if mise plugins list | awk '{print $1}' | grep -qx "$name"; then
    echo "Plugin already installed: $name" >&2
    continue
  fi
  if [[ -n "${repo:-}" ]]; then
    echo "Adding mise plugin: $name ($repo)"
    mise use "$name" "$repo"
  else
    echo "Adding mise plugin: $name"
    mise use "$name"
  fi
done

echo "Done."
