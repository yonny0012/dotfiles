#!/usr/bin/env bash
# ============================================
# Control de volumen para Eww
# Requiere: pamixer (apt install pamixer)
# ============================================

case "$1" in
  get)
    pamixer --get-volume 2>/dev/null || echo "0"
    ;;
  
  icon)
    if pamixer --get-mute &>/dev/null; then
      echo "󰖁"  # Mute
    else
      vol=$(pamixer --get-volume)
      if [ "$vol" -eq 0 ]; then
        echo "󰕿"
      elif [ "$vol" -lt 50 ]; then
        echo "󰖀"
      else
        echo "󰕾"
      fi
    fi
    ;;
  
  toggle)
    pamixer -t
    ;;
  
  set)
    pamixer --set-volume "$2"
    ;;
  
  *)
    echo "Uso: $0 {get|icon|toggle|set <valor>}"
    exit 1
    ;;
esac