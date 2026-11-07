# ==============================================================================
# Fish Config: 00-env.fish
# Entorno base y PATH
# Las variables de Wayland/Hyprland van en hypr/conf.d/env.lua
# ==============================================================================

# Editor predeterminado (Neovim si existe, si no, Nano/Vim)
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
else
    set -gx EDITOR vim
end

# Terminal predeterminada
set -gx TERMINAL kitty

# Tema general (para herramientas CLI compatibles, ej. bat)
set -gx BAT_THEME "Catppuccin Macchiato"
set -gx THEME_FLAVOUR "macchiato"

# Configuración del paginador (less)
set -gx PAGER less
set -gx LESS "-R --use-color"

# Variables de Go (el binario `go` viene de apt en /usr/bin)
set -gx GOPATH $HOME/go

# PATH de usuario. `-g` evita que fish_add_path persista rutas en
# fish_variables (universales); así el PATH se define solo aquí.
fish_add_path -g $GOPATH/bin
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.local/bin

# variables de sistema para conexion
# set -gx HTTP_PROXY "10.0.0.1:8080"
# set -gx HTTPS_PROXY "10.0.0.1:8080"
# set -gx NO_PROXY "10.*, localhost, *uci.cu"
# set -gx http_proxy "10.0.0.1:8080"
# set -gx https_proxy "10.0.0.1:8080"
# set -gx no_proxy "10.*, localhost, *uci.cu"

# === === === === ===
# Java (JDK)
# === === === === ===
# JAVA_HOME fijado a JDK 17 (Android/Odoo) aunque haya otros JDK instalados.
# Si ese JDK no existe, JAVA_HOME queda sin definir y las herramientas usan el
# `java` del PATH (un JAVA_HOME inválido rompe Gradle y sdkmanager).
# Para seguir al `java` activo de update-alternatives, usar la línea comentada.
set -l jdk17 /usr/lib/jvm/jdk-17.0.0.1
if type -q java; and test -x $jdk17/bin/java
    # set -gx JAVA_HOME (path resolve (command -v java) | path dirname | path dirname)
    set -gx JAVA_HOME $jdk17
    fish_add_path --move --prepend $JAVA_HOME/bin
end

# === === === === ===
# Android SDK
# === === === === ===
# SDK instalado a mano en ~/android/sdk, no en ~/Android/Sdk (la ruta por
# defecto de Android Studio). Si se usa Android Studio, cambiar esta línea.
set -gx ANDROID_HOME $HOME/android/sdk

# Rutas de herramientas del SDK. `tools/` y `tools/bin` están obsoletos:
# su reemplazo es cmdline-tools/latest/bin (sdkmanager, avdmanager).
# fish_add_path omite los directorios que aún no existen.
fish_add_path -g $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path -g $ANDROID_HOME/emulator
fish_add_path -g $ANDROID_HOME/platform-tools

# === === === === ===
# MPD / MPC (Socket Unix de bajo consumo)
# === === === === ===
if test -S $HOME/.local/state/mpd/socket
    set -gx MPD_HOST $HOME/.local/state/mpd/socket
end
