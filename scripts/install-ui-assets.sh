#!/usr/bin/env bash
# install-ui-assets.sh - Copia el fondo y la config del greeter de LightDM
# (slick-greeter) a rutas del sistema. $HOME es 700, así que lightdm no puede
# leerlos desde el repo: hay que copiarlos, no enlazarlos.
# Uso: bash ~/dotfiles/scripts/install-ui-assets.sh   (pide sudo)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKGROUND_SRC="$DOTFILES_DIR/wallpapers/Pictures/wallpapers/background.jpg"
GREETER_SRC="$DOTFILES_DIR/system/etc/lightdm/slick-greeter.conf"
LIGHTDM_SRC="$DOTFILES_DIR/system/etc/lightdm/lightdm.conf.d/50-dotfiles.conf"

for f in "$BACKGROUND_SRC" "$GREETER_SRC" "$LIGHTDM_SRC"; do
    [ -f "$f" ] || { echo "Error: no existe $f"; exit 1; }
done

sudo install -Dm644 "$BACKGROUND_SRC" /usr/share/backgrounds/background.jpg
sudo install -Dm644 "$GREETER_SRC" /etc/lightdm/slick-greeter.conf
# Fija slick-greeter y Hyprland como sesión por defecto.
sudo install -Dm644 "$LIGHTDM_SRC" /etc/lightdm/lightdm.conf.d/50-dotfiles.conf
echo "✅ Fondo, greeter y sesión por defecto instalados. Se verán en el próximo inicio de sesión."
