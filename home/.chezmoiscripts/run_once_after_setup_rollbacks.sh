#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err() { printf 'ERROR: %s\n' "$*" >&2; }

require_cmd() { command -v "$1" >/dev/null 2>&1; }

CURRENT_USER="${SUDO_USER:-${USER:-$(id -un)}}"

log "Setting up Snapper rollbacks and integrations..."

if ! require_cmd snapper; then
  warn "snapper not installed. Install 'snapper' and rerun this script. Skipping."
  exit 0
fi

if ! require_cmd btrfs; then
  warn "btrfs-progs not installed. Install 'btrfs-progs' and rerun this script. Skipping."
  exit 0
fi

rootfs=$(findmnt -no FSTYPE / || true)
if [[ "${rootfs}" != "btrfs" ]]; then
  err "Root filesystem is not Btrfs. Nothing to do."
  exit 0
fi

log "Enabling Btrfs quota on /."
sudo btrfs quota enable / 2>/dev/null || true

ensure_snapshots_perms() {
  local path="$1"
  if [[ -d "${path}" ]]; then
    sudo chmod 750 "${path}" || true
  fi
}

set_snapper_opt() {
  local cfg_file="$1"
  shift
  local key="$1"
  shift
  local value="$1"
  shift
  if sudo grep -qE "^\s*${key}=" "${cfg_file}"; then
    sudo sed -i "s|^\s*${key}=.*|${key}=\"${value}\"|" "${cfg_file}"
  else
    printf '%s\n' "${key}=\"${value}\"" | sudo tee -a "${cfg_file}" >/dev/null
  fi
}

configure_snapper_cfg() {
  local name="$1"
  local cfg="/etc/snapper/configs/${name}"
  [[ -f "${cfg}" ]] || return 0
  set_snapper_opt "${cfg}" ALLOW_USERS "${CURRENT_USER}"
  set_snapper_opt "${cfg}" TIMELINE_CREATE "yes"
  set_snapper_opt "${cfg}" TIMELINE_LIMIT_HOURLY "8"
  set_snapper_opt "${cfg}" TIMELINE_LIMIT_DAILY "7"
  set_snapper_opt "${cfg}" TIMELINE_LIMIT_WEEKLY "4"
  set_snapper_opt "${cfg}" TIMELINE_LIMIT_MONTHLY "6"
  set_snapper_opt "${cfg}" TIMELINE_LIMIT_YEARLY "1"
  set_snapper_opt "${cfg}" NUMBER_CLEANUP "yes"
  set_snapper_opt "${cfg}" NUMBER_MIN_AGE "1800"
  set_snapper_opt "${cfg}" NUMBER_LIMIT "50"
  set_snapper_opt "${cfg}" NUMBER_LIMIT_IMPORTANT "10"
}

# Root config
if [[ ! -f /etc/snapper/configs/root ]]; then
  log "Creating snapper config 'root' for /."
  sudo snapper -c root create-config /
else
  log "Snapper config 'root' already exists."
fi
configure_snapper_cfg root
ensure_snapshots_perms "/.snapshots"

# Home config (optional)
homefs=$(findmnt -no FSTYPE /home || true)
if [[ "${homefs}" == "btrfs" ]]; then
  if [[ ! -f /etc/snapper/configs/home ]]; then
    log "Creating snapper config 'home' for /home."
    sudo snapper -c home create-config /home
  else
    log "Snapper config 'home' already exists."
  fi
  configure_snapper_cfg home
  ensure_snapshots_perms "/home/.snapshots"
else
  warn "/home is not on Btrfs; skipping 'home' config."
fi

# Enable timeline and cleanup timers
if systemctl list-unit-files | grep -q '^snapper-timeline.timer'; then
  log "Enabling snapper timers."
  sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer || true
else
  warn "Snapper timers not found; are snapper services installed?"
fi

# Check snap-pac for automatic pacman snapshots
if pacman -Q snap-pac >/dev/null 2>&1; then
  log "snap-pac is installed - automatic pacman snapshots enabled."
else
  warn "snap-pac not installed. Install with: sudo pacman -S snap-pac"
fi
log "Snapper rollback setup completed."

