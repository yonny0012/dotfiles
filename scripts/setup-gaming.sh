#!/usr/bin/env bash
# setup-gaming.sh - Prepara Debian (testing) para juegos de Windows vía
# Steam/Proton + Heroic, con herramientas de medición y perfil de rendimiento
# acotado a la sesión de juego (no toca el rendimiento para desarrollo).
# Uso: bash ~/dotfiles/scripts/setup-gaming.sh   (pide sudo)
#
# Referencias y decisiones: ver GAMING.md en la raíz del repo.

set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
USER_UID="$(id -u "$USER_NAME")"

# Huella de la clave del repo oficial de Valve (repo.steampowered.com).
# Se verifica antes de confiar en el repo: si no coincide, el script aborta.
VALVE_KEY_FPR="BA1816EF8E75005FCF5E27A1F24AEA9FB05498B7"

# Herramientas de medición y perfil de rendimiento. Todas en testing/main.
TOOLS=(gamemode mangohud goverlay vkbasalt vulkan-tools mesa-utils earlyoom)
# steam-devices aporta las reglas udev de mandos (Xbox/DualSense/Switch Pro).
UDEV_PKG=steam-devices

# Librerías de 32 bits: la mayoría de juegos de Windows son i386 y Proton las
# necesita en el host aunque el Steam Linux Runtime aporte el resto. Se instalan
# una por una para que un nombre ausente no aborte todo el script.
PKGS_I386=(mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 libvulkan1:i386
           mangohud:i386 libgamemodeauto0:i386 libgamemode0:i386)

if ! command -v apt-get >/dev/null; then
    echo "✗ Este script es para Debian/derivados (no se encontró apt-get)." >&2
    exit 1
fi

echo "==> [1/6] Arquitectura i386 (requisito de Steam)"
# Idempotente: dpkg no duplica la arquitectura si ya está añadida.
sudo dpkg --add-architecture i386
sudo apt-get update

echo "==> [2/6] Cliente de Steam"
# En testing, `steam-installer` existe como fuente pero SIN binario publicado
# (verificado en el índice de testing y en api.ftp-master.debian.org), y en
# stable vive en `contrib`, que este sistema no tiene habilitado. Por eso:
#   1) se intenta el paquete de Debian (queda automático si vuelve a testing),
#   2) si no hay candidato, se usa el .deb oficial de Valve, que es el método
#      soportado por Valve para Debian y trae steam-libs-{amd64,i386}.
CANDIDATE="$(apt-cache policy steam-installer 2>/dev/null | awk '/Candidate:/ {print $2}')"

if [ -n "$CANDIDATE" ] && [ "$CANDIDATE" != "(none)" ]; then
    echo "    Usando el paquete de Debian: steam-installer $CANDIDATE"
    sudo apt-get install -y steam-installer
else
    echo "    Sin binario de steam-installer en testing → repo oficial de Valve"

    sudo install -d -m 0755 /etc/apt/keyrings
    sudo curl -fsSL https://repo.steampowered.com/steam/archive/stable/steam.gpg \
        -o /etc/apt/keyrings/steam.gpg
    sudo chmod 0644 /etc/apt/keyrings/steam.gpg

    FPR="$(gpg --show-keys --with-colons /etc/apt/keyrings/steam.gpg 2>/dev/null \
           | awk -F: '/^fpr:/ {print $10; exit}')"
    if [ "$FPR" != "$VALVE_KEY_FPR" ]; then
        echo "✗ La clave de Valve no coincide." >&2
        echo "  esperada: $VALVE_KEY_FPR" >&2
        echo "  obtenida: ${FPR:-<ilegible>}" >&2
        exit 1
    fi
    echo "    Clave verificada: Valve Corporation <linux@steampowered.com>"

    sudo tee /etc/apt/sources.list.d/steam.sources >/dev/null <<'EOF'
Types: deb
URIs: https://repo.steampowered.com/steam/
Suites: stable
Components: steam
Architectures: amd64 i386
Signed-By: /etc/apt/keyrings/steam.gpg
EOF

    sudo apt-get update
    sudo apt-get install -y steam-launcher
fi
sudo apt-get install -y "$UDEV_PKG"

echo "==> [3/6] Librerías de 32 bits"
FAILED=()
for pkg in "${PKGS_I386[@]}"; do
    if sudo apt-get install -y "$pkg" >/dev/null 2>&1; then
        printf '    ✓ %s\n' "$pkg"
    else
        printf '    · %s (no disponible, se omite)\n' "$pkg"
        FAILED+=("$pkg")
    fi
done
if [ ${#FAILED[@]} -gt 0 ]; then
    echo "    Aviso: revisá esos nombres en testing; el resto del setup continúa."
fi

echo "==> [4/6] GameMode, MangoHud y utilidades"
sudo apt-get install -y "${TOOLS[@]}"

echo "==> [5/6] Heroic Games Launcher (Flatpak)"
# Heroic no está empaquetado en Debian; Flathub es la vía oficial mantenida.
if ! command -v flatpak >/dev/null; then
    sudo apt-get install -y flatpak
fi
sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.heroicgameslauncher.hgl

echo "==> [6/6] Servicio de GameMode (modo usuario)"
# gamemoded es un servicio de usuario; se activa para el usuario real, no root.
sudo -u "$USER_NAME" \
    XDG_RUNTIME_DIR="/run/user/$USER_UID" \
    systemctl --user enable --now gamemoded 2>/dev/null \
    || echo "    · Activá gamemoded a mano: systemctl --user enable --now gamemoded"

cat <<'EOF'

✅ Instalación terminada.

Pasos manuales (una sola vez):

  1. Abrí Steam, logueate y activá Proton:
     Steam → Ajustes → Compatibilidad → "Habilitar Steam Play para todos los títulos".

  2. Desplegá los configs del repo:
       cd ~/dotfiles && stow gamemode mangohud fish hypr

  3. Por juego → Propiedades → Opciones de lanzamiento:
       gamemoderun mangohud %command%

     En esta iGPU conviene además el FSR interno de Proton:
       WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=2 gamemoderun mangohud %command%
     (en Fish: `opciones-fsr 2` imprime la cadena ya armada)

  4. Verificá que Vulkan ve el driver Intel:
       vulkaninfo --summary | head -20

  Qué se instaló, por qué, y qué se evitó a propósito: GAMING.md
EOF
