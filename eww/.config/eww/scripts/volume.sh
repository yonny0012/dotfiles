#!/usr/bin/env bash
# ============================================
# Control de volumen para Eww
# Requiere: wireplumber (wpctl)
# ============================================

case "$1" in
  get)
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null \
      | awk '{print int($2 * 100)}' || echo "0"
    ;;

  icon)
    local_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if echo "$local_output" | grep -q MUTED; then
      echo "󰖁"  # Mute
    else
      vol=$(echo "$local_output" | awk '{print int($2 * 100)}')
      if [ "${vol:-0}" -eq 0 ]; then
        echo "󰕿"
      elif [ "${vol:-0}" -lt 50 ]; then
        echo "󰖀"
      else
        echo "󰕾"
      fi
    fi
    ;;

  toggle)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;

  set)
    # Clamp to 150% max (wpctl allows > 100%)
    local_val="${2:-0}"
    if [ "$local_val" -gt 150 ] 2>/dev/null; then
      local_val=150
    fi
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${local_val}%"
    ;;

  *)
    echo "Uso: $0 {get|icon|toggle|set <valor>}"
    exit 1
    ;;
esac