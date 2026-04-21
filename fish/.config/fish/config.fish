# ==============================================================================
# Fish Config (Principal)
# Archivo de inicialización base. Mantenido lo más pequeño posible.
# ==============================================================================

# Si no estamos en una sesión interactiva, salir temprano
status is-interactive || exit

# --- [ Supresión de Bienvenida ] ----------------------------------------------
set fish_greeting ""

# --- [ Variables de Colores para Fish ] ---------------------------------------
# Tema: Catppuccin Macchiato
set -g fish_color_normal cad3f5
set -g fish_color_command 8aadf4
set -g fish_color_param f5bde6
set -g fish_color_keyword ed8796
set -g fish_color_quote a6da95
set -g fish_color_redirection f5bde6
set -g fish_color_end f5a97f
set -g fish_color_error ed8796
set -g fish_color_gray 5b6078
set -g fish_color_selection --background=363a4f
set -g fish_color_search_match --background=363a4f
set -g fish_color_option a6da95
set -g fish_color_operator f5bde6
set -g fish_color_escape ed8796
set -g fish_color_autosuggestion 5b6078
set -g fish_color_cancel ed8796
set -g fish_color_cwd eed49f
set -g fish_color_user 8bd5ca
set -g fish_color_host 8aadf4
set -g fish_color_host_remote a6da95
set -g fish_pager_color_progress 5b6078
set -g fish_pager_color_prefix f5bde6
set -g fish_pager_color_completion cad3f5
set -g fish_pager_color_description 5b6078

# --- [ Inicialización de Prompt (Starship) ] ----------------------------------
if type -q starship
    starship init fish | source
end