#!/usr/bin/env bash
# ==============================================================================
# toggle-power-menu.sh
# Abre o cierra el power menu eww según su estado actual.
# Llamado desde: keybinds.conf → bind = $mainMod, q, exec, ...
# ==============================================================================
 
set -euo pipefail
 
WINDOW="power-menu"
 
# NOTA: eww active-windows output es "window_id: window_name"
if eww active-windows 2>/dev/null | grep -q "^${WINDOW}:"; then
    # Ya está abierto → resetear estado y cerrar
    eww update power-confirm-visible=false
    eww close "$WINDOW"
else
    # Está cerrado → limpiar variables y abrir
    eww update \
        power-confirm-visible=false \
        power-confirm-action="" \
        power-confirm-label="" \
        power-confirm-icon=""
    eww open "$WINDOW"
fi
 