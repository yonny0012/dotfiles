# ==============================================================================
# Fish Config: 20-integrations.fish
# Inicialización de herramientas (lazy-loading gestionado por Fish)
# ==============================================================================

# Si no estamos en una sesión interactiva, salir temprano
status is-interactive || exit

# --- [ Zoxide (Reemplazo de cd) ] ---------------------------------------------
if type -q zoxide
    zoxide init fish | source
    alias cd="z"
    alias cdi="zi"
end

# --- [ fzf (Búsqueda difusa) ] ------------------------------------------------
# Si existe FZF, pero no se inyectan keybindings pesados. Preferir Fisher para
# fzf.fish o configurarlo manualmente en functions/ si hiciera falta.
if type -q fzf
    set -gx FZF_DEFAULT_OPTS "--height=50% --min-height=15 --reverse --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
    if type -q fdfind
        set -gx FZF_DEFAULT_COMMAND "fdfind --type f --hidden --exclude .git"
    end
end