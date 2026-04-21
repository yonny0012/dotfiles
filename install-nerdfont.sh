#!/usr/bin/env bash
set -e
echo "Descargando JetBrainsMono Nerd Font..."
mkdir -p ~/.local/share/fonts
cd /tmp
wget -qO JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -qo JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv
echo "✅ JetBrainsMono Nerd Font instalada exitosamente en ~/.local/share/fonts"
rm JetBrainsMono.zip
