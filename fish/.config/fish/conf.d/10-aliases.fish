# ==============================================================================
# Fish Config: 10-aliases.fish
# Alias de navegación y herramientas CLI modernas
# ==============================================================================

# --- [ Comandos base de seguridad ] -------------------------------------------
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias df="df -h"
alias du="du -h"

# --- [ Herramientas CLI Modernas ] --------------------------------------------
# Reemplazo de ls por eza (si está instalado)
if type -q eza
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -lh --icons --group-directories-first"
    alias la="eza -lah --icons --group-directories-first"
    alias tree="eza --tree --icons"
end

# Reemplazo de cat por bat (si está instalado)
# (en Debian el binario se llama batcat)
if type -q batcat
    alias bat="batcat"
    alias cat="batcat -p" # Texto plano
    alias catn="batcat"   # Con números de línea y sintaxis
end

# Reemplazo de find por fd (si está instalado)
if type -q fdfind
    alias fd="fdfind"
end

# --- [ Zellij & Tmux ] --------------------------------------------------------
# Arrancar el layout de desarrollo de Zellij (si está instalado)
if type -q zellij
    alias dev="zellij --layout dev"
    alias zj="zellij"
    alias zjls="zellij list-sessions"
    alias zja="zellij attach"
end

# --- [ Git y Stow ] -----------------------------------------------------------
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate --all"
alias gd="git diff"

alias st="stow --target=\$HOME"
alias unst="stow --delete --target=\$HOME"

# --- [ Música / MPD & MPC ] ---------------------------------------------------
if type -q mpc
    alias play="mpc toggle"
    alias next="mpc next"
    alias prev="mpc prev"
    alias song="mpc current"
end