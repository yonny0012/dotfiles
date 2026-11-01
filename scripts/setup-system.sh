#!/usr/bin/env bash
# setup-system.sh - Instala dependencias del setup Hyprland, elimina Cinnamon
# y deja fish/kitty como shell y terminal por defecto.
# Uso: bash ~/dotfiles/scripts/setup-system.sh   (pide sudo)

set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

# Paquetes que deben sobrevivir al autoremove (hoy están como "automáticos"
# porque entraron como dependencias de Cinnamon)
KEEP=(lightdm slick-greeter lightdm-settings xserver-xorg xwayland
      gnome-keyring gvfs gvfs-backends gvfs-fuse thunar-volman tumbler
      xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-terminal-exec
      pipewire-pulse wireplumber)

# Dependencias del setup (binarios que usan hypr, waybar, eww y fish)
PKGS=(btop sway-notification-center hyprlock hypridle swaybg cliphist wl-clipboard
      grim slurp brightnessctl playerctl udiskie pavucontrol hyprpolkitagent
      fzf zoxide eza bat jq libnotify-bin papirus-icon-theme
      bibata-cursor-theme golang-go)

# Dependencias de compilación de eww (no está en los repos de Debian)
EWW_BUILD=(build-essential pkg-config libgtk-3-dev libgtk-layer-shell-dev
           libdbusmenu-gtk3-dev libpango1.0-dev libgdk-pixbuf-2.0-dev
           libcairo2-dev libglib2.0-dev)

# Entorno Cinnamon/GNOME que no se usa (solo Hyprland + Thunar)
PURGE=('cinnamon*' 'nemo*' muffin muffin-common cjs metacity metacity-common
       gnome-terminal gnome-terminal-data nautilus-extension-gnome-terminal
       gnome-online-accounts gnome-online-accounts-gtk gnome-backgrounds
       mate-icon-theme xdg-desktop-portal-xapp)

echo "==> [1/7] Protegiendo paquetes necesarios"
sudo apt-mark manual "${KEEP[@]}"

echo "==> [2/7] Instalando dependencias"
sudo apt-get update
sudo apt-get install -y "${PKGS[@]}" "${EWW_BUILD[@]}"
# Dependencias de compilación de waybar (requiere deb-src habilitado)
sudo apt-get build-dep -y waybar

echo "==> [3/7] Eliminando Cinnamon y aplicaciones GNOME"
sudo apt-get purge -y "${PURGE[@]}"

echo "==> [4/7] Dependencias huérfanas (revisa la lista antes de confirmar)"
sudo apt-get autoremove --purge

echo "==> [5/7] Shell y terminal por defecto"
sudo chsh -s /usr/bin/fish "$USER_NAME"
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator "$USER_HOME/.local/bin/kitty" 60
sudo update-alternatives --set x-terminal-emulator "$USER_HOME/.local/bin/kitty"

echo "==> [6/7] Compilando eww (Wayland)"
EWW_SRC="${EWW_SRC:-/tmp/eww}"
[ -d "$EWW_SRC" ] || git clone https://github.com/elkowar/eww "$EWW_SRC"
export PATH="$USER_HOME/.cargo/bin:$PATH"
(cd "$EWW_SRC" && cargo build --release --no-default-features --features=wayland -p eww)
install -Dm755 "$EWW_SRC/target/release/eww" "$USER_HOME/.local/bin/eww"
"$USER_HOME/.local/bin/eww" --version

# El waybar 0.15.0 de Debian no habla el protocolo de dispatch de Hyprland con
# config Lua (los clics en workspaces no hacen nada); el soporte está en git.
# Se instala en ~/.local, que va antes que /usr/bin en el PATH de Hyprland.
echo "==> [7/7] Compilando waybar (git)"
WAYBAR_SRC="${WAYBAR_SRC:-/tmp/waybar}"
[ -d "$WAYBAR_SRC" ] || git clone https://github.com/Alexays/Waybar "$WAYBAR_SRC"
(cd "$WAYBAR_SRC" \
    && meson setup build --prefix="$USER_HOME/.local" --buildtype=release \
        -Dtests=disabled -Dsystemd=disabled --reconfigure \
    && meson install -C build --skip-subprojects)
"$USER_HOME/.local/bin/waybar" --version

echo "✅ Listo. Cierra sesión y vuelve a entrar para aplicar shell y autostart."
