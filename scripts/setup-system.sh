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

echo "==> [1/8] Protegiendo paquetes necesarios"
sudo apt-mark manual "${KEEP[@]}"

echo "==> [2/8] Instalando dependencias"
sudo apt-get update
sudo apt-get install -y "${PKGS[@]}" "${EWW_BUILD[@]}"
# Dependencias de compilación de waybar (requiere deb-src habilitado)
sudo apt-get build-dep -y waybar

echo "==> [3/8] Eliminando Cinnamon y aplicaciones GNOME"
sudo apt-get purge -y "${PURGE[@]}"

echo "==> [4/8] Dependencias huérfanas (revisa la lista antes de confirmar)"
sudo apt-get autoremove --purge

echo "==> [5/8] Shell, terminal y directorios de usuario"
sudo chsh -s /usr/bin/fish "$USER_NAME"
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator "$USER_HOME/.local/bin/kitty" 60
sudo update-alternatives --set x-terminal-emulator "$USER_HOME/.local/bin/kitty"
# mpd.conf usa rutas XDG y mpd no crea la carpeta del socket: sin ella el
# servicio no arranca. Se crean como el usuario real (no root).
sudo -u "$USER_NAME" install -d "$USER_HOME/.local/share/mpd/playlists" \
    "$USER_HOME/.local/state/mpd"

echo "==> [6/8] Compilando eww (Wayland)"
EWW_SRC="${EWW_SRC:-/tmp/eww}"
[ -d "$EWW_SRC" ] || git clone https://github.com/elkowar/eww "$EWW_SRC"
export PATH="$USER_HOME/.cargo/bin:$PATH"
(cd "$EWW_SRC" && cargo build --release --no-default-features --features=wayland -p eww)
install -Dm755 "$EWW_SRC/target/release/eww" "$USER_HOME/.local/bin/eww"
"$USER_HOME/.local/bin/eww" --version

# El waybar 0.15.0 de Debian no habla el protocolo de dispatch de Hyprland con
# config Lua (los clics en workspaces no hacen nada); el soporte está en git.
# Se instala en ~/.local, que va antes que /usr/bin en el PATH de Hyprland.
echo "==> [7/8] Compilando waybar (git)"
WAYBAR_SRC="${WAYBAR_SRC:-/tmp/waybar}"
[ -d "$WAYBAR_SRC" ] || git clone https://github.com/Alexays/Waybar "$WAYBAR_SRC"
(cd "$WAYBAR_SRC" \
    && meson setup build --prefix="$USER_HOME/.local" --buildtype=release \
        -Dtests=disabled -Dsystemd=disabled --reconfigure \
    && meson install -C build --skip-subprojects)
"$USER_HOME/.local/bin/waybar" --version

# Rendimiento: memoria, red, OOM y térmica. Detalle y documentación en el
# README (sección "Rendimiento del sistema"). Los archivos viven en
# system/etc/ y se copian tal cual a /etc.
echo "==> [8/8] Optimización de rendimiento"
SYS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/system/etc"
sudo apt-get install -y earlyoom thermald irqbalance zram-tools
for f in sysctl.d/99-performance.conf default/earlyoom \
         tmpfiles.d/thp-madvise.conf modules-load.d/bbr.conf; do
    sudo install -Dm644 "$SYS_DIR/$f" "/etc/$f"
done
sudo modprobe tcp_bbr
sudo sysctl --system > /dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/thp-madvise.conf
sudo systemctl enable --now thermald.service irqbalance.service
sudo systemctl restart earlyoom.service
# zstd comprime más que lz4; aplica en el próximo arranque (reiniciar zram
# con swap en uso puede congelar el equipo).
set_zram() {  # set_zram KEY VALUE: fija la clave, descomentándola o añadiéndola
    if grep -q "^#\?$1=" /etc/default/zramswap; then
        sudo sed -i "s/^#\?$1=.*/$1=$2/" /etc/default/zramswap
    else
        echo "$1=$2" | sudo tee -a /etc/default/zramswap > /dev/null
    fi
}
set_zram ALGO zstd
set_zram PERCENT 50
# noatime en la raíz: evita una escritura por cada lectura de archivo.
# Se edita y valida una copia; /etc/fstab solo se reemplaza si la copia es
# válida, así un error nunca deja un fstab roto para el próximo arranque.
FSTAB_NEW="$(mktemp)"
awk 'BEGIN { OFS = "\t" }
     $1 !~ /^#/ && $2 == "/" {
         n = split($4, opts, ","); out = "noatime"
         for (i = 1; i <= n; i++)
             if (opts[i] !~ /^(noatime|relatime|strictatime|atime)$/) out = out "," opts[i]
         if (out != $4) $4 = out
     }
     { print }' /etc/fstab > "$FSTAB_NEW"
if ! cmp -s /etc/fstab "$FSTAB_NEW"; then
    findmnt --verify --tab-file "$FSTAB_NEW" > /dev/null
    sudo cp /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d%H%M%S)"
    sudo install -m644 "$FSTAB_NEW" /etc/fstab
fi
rm -f "$FSTAB_NEW"
findmnt -no OPTIONS / | grep -qw noatime || sudo mount -o remount,noatime /
# Servicios que no hacen falta al arranque en este equipo (se omiten si no
# existen). Docker y Odoo se arrancan a mano: sudo systemctl start docker|odoo
for unit in ModemManager.service avahi-daemon.service avahi-daemon.socket \
            odoo.service docker.service docker.socket containerd.service; do
    if systemctl list-unit-files "$unit" --no-legend | grep -q .; then
        sudo systemctl disable "$unit"
    fi
done

echo "✅ Listo. Cierra sesión y vuelve a entrar para aplicar shell y autostart."
