# ==============================================================================
# Fish Config: 00-env.fish
# Entorno base y PATH
# Las variables de Wayland/Hyprland van en hypr/conf.d/env.conf
# ==============================================================================

# Editor predeterminado (Neovim si existe, si no, Nano/Vim)
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
else
    set -gx EDITOR vim
end

# Tema general (para herramientas CLI compatibles, ej. bat)
set -gx BAT_THEME "Catppuccin Macchiato"
set -gx THEME_FLAVOUR "macchiato"

# Configuración del paginador (less)
set -gx PAGER less
set -gx LESS "-R --use-color"

# Agregar scripts de usuario al PATH
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.go/bin