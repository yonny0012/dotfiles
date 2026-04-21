#!/usr/bin/env bash
# ============================================
# Script de información del sistema para Eww
# Compatible con Debian GNU/Linux
# ============================================

case "$1" in
  cpu)
    # Uso de CPU: promedio de carga en 1 segundo
    top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}'
    ;;
  
  ram)
    # Porcentaje de RAM usada
    free | awk '/Mem:/ {printf "%.0f", ($3/$2) * 100}'
    ;;
  
  disk)
    # Porcentaje del disco raíz usado
    df -h / | awk 'NR==2 {print int($5)}'
    ;;
  
  net)
    # Velocidad de red (requiere calcular diferencia)
    # Versión simple: muestra interfaces activas
    interface=$(ip route | awk '/default/ {print $5; exit}')
    rx1=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx1=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    sleep 1
    rx2=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx2=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    
    rx_speed=$(( (rx2 - rx1) / 1024 ))
    tx_speed=$(( (tx2 - tx1) / 1024 ))
    
    echo "↓${rx_speed}KB ↑${tx_speed}KB"
    ;;
  
  gpu)
    # Detección automática de GPU
    if command -v nvidia-smi &> /dev/null; then
      # NVIDIA
      nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1 | tr -d ' '
    elif [ -d /sys/class/drm/card0/device ]; then
      # AMD/Intel (requiere lectura de hwmon si disponible)
      cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "0"
    else
      echo "N/A"
    fi
    ;;
  
  *)
    echo "Uso: $0 {cpu|ram|disk|net|gpu}"
    exit 1
    ;;
esac