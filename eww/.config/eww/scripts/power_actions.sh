#!/usr/bin/env bash
set -euo pipefail

# power_actions.sh
#
# Usage:
#   power_actions.sh <poweroff|restart|logout>
#
# Security notes:
# - Action is mandatory and strictly validated against an allow-list.
# - Any other value is rejected with non-zero exit status.
#
# Logout behavior:
# - Uses Hyprland dispatcher to close the current session (`hyprctl dispatch exit`).

usage() {
  printf 'Usage: %s <poweroff|restart|logout>\n' "${0##*/}" >&2
}

main() {
  local action="${1:-}"

  case "$action" in
    poweroff)
      exec systemctl poweroff
      ;;
    restart)
      exec systemctl reboot
      ;;
    logout)
      exec hyprctl dispatch exit
      ;;
    *)
      usage
      printf 'Invalid action: %s\n' "${action:-<empty>}" >&2
      exit 2
      ;;
  esac
}

main "$@"
