#!/usr/bin/env bash
set -euo pipefail

fzf_args=(
  --multi
  --cycle
  --reverse
  --prompt 'mise installed> '
  --preview 'mise plugins list | paste -s -d "," -'
  --preview-window 'down:25%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
)

if ! command -v mise >/dev/null 2>&1; then
  echo "mise not found in PATH" >&2
  exit 1
fi

# Only pass plugin names to fzf (first column)
mapfile -t selections < <(mise ls | awk '{print $1}' | fzf "${fzf_args[@]}")

if [[ ${#selections[@]} -eq 0 ]]; then
  exit 0
fi

for name in "${selections[@]}"; do
  echo "Removing mise plugin: $name"
  mise unuse "$name"
done

echo "Done."
