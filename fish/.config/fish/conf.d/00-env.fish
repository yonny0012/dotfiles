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
# Android SDK
# === === === === ===
set -gx ANDROID_HOME $HOME/Android/Sdk

# Agregar las rutas de herramientas al PATH
set -gx PATH $ANDROID_HOME/emulator $PATH
set -gx PATH $ANDROID_HOME/tools $PATH
set -gx PATH $ANDROID_HOME/tools/bin $PATH
set -gx PATH $ANDROID_HOME/platform-tools $PATH
