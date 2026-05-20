#!/bin/bash
# install-ui-assets.sh - Sync backgrounds and Regreet config to system paths

set -e

# Paths
DOTFILES_DIR="$HOME/dotfiles"
BACKGROUND_SRC="$DOTFILES_DIR/wallpapers/Pictures/wallpapers/background.jpg"
REGREET_CONFIG_SRC="$DOTFILES_DIR/regreet/etc/greetd/regreet.toml"
REGREET_STYLE_SRC="$DOTFILES_DIR/regreet/etc/greetd/style.css"

BACKGROUND_DEST="/usr/share/backgrounds/background.jpg"
GREETD_DIR="/etc/greetd"

echo "Checking assets..."

if [ ! -f "$BACKGROUND_SRC" ]; then
    echo "Error: Background source not found at $BACKGROUND_SRC"
    exit 1
fi

echo "To install these assets, run the following commands with sudo:"
echo ""
echo "sudo mkdir -p /usr/share/backgrounds"
echo "sudo cp \"$BACKGROUND_SRC\" \"$BACKGROUND_DEST\""
echo "sudo cp \"$REGREET_CONFIG_SRC\" \"$GREETD_DIR/regreet.toml\""
echo "sudo cp \"$REGREET_STYLE_SRC\" \"$GREETD_DIR/style.css\""
echo "sudo chmod 644 \"$BACKGROUND_DEST\" \"$GREETD_DIR/regreet.toml\" \"$GREETD_DIR/style.css\""
echo ""
echo "Note: The home directory $HOME is 700, so assets must be in system paths."
