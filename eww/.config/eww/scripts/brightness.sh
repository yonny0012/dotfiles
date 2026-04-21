#!/usr/bin/env bash
# ============================================
# Control de brillo para Eww
# Requiere: brightnessctl (apt install brightnessctl)
# ============================================

case "$1" in
  get)
    brightnessctl -m | awk -F, '{print int($4)}' 2>/dev/null || echo "100"
    ;;
  
  icon)
    level=$(brightnessctl -m | awk -F, '{print int($4)}' 2>/dev/null || echo "100")
    if [ "$level" -lt 30 ]; then
      echo "󰃚"
    elif [ "$level" -lt 70 ]; then
      echo "󰃛"
    else
      echo "󰃜"
    fi
    ;;
  
  set)
    brightnessctl set "${2}%"
    ;;
  
  *)
    echo "Uso: $0 {get|icon|set <valor>}"
    exit 1
    ;;
esac