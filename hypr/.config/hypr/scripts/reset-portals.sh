#!/usr/bin/env sh

# Reinicia portales Wayland para evitar delays largos (10-25s) en atajos.
# Útil cuando conviven backends conflictivos (gnome/kde/hyprland).

set -eu

pick_bin() {
  if [ -x "$1" ]; then
    printf '%s' "$1"
    return 0
  fi
  if [ -x "$2" ]; then
    printf '%s' "$2"
    return 0
  fi
  return 1
}

HYPR_PORTAL_BIN="$(pick_bin /usr/lib/xdg-desktop-portal-hyprland /usr/libexec/xdg-desktop-portal-hyprland || true)"
PORTAL_BIN="$(pick_bin /usr/lib/xdg-desktop-portal /usr/libexec/xdg-desktop-portal || true)"

killall -q xdg-desktop-portal-hyprland xdg-desktop-portal-gnome xdg-desktop-portal-kde xdg-desktop-portal || true

if [ -n "${HYPR_PORTAL_BIN}" ]; then
  "$HYPR_PORTAL_BIN" &
fi

sleep 2

if [ -n "${PORTAL_BIN}" ]; then
  "$PORTAL_BIN" &
fi
