# ==============================================================================
# Manual Tool Paths (Node, pnpm, fnm, etc.)
# Cada bloque se activa solo si la herramienta está instalada.
# Rust/Cargo: lo gestiona conf.d/rustup.fish
# ==============================================================================

# OpenCode / Agent Teams Lite
if test -d ~/.opencode/bin
    fish_add_path -g ~/.opencode/bin
end

# pnpm
if test -d ~/.local/share/pnpm
    set -gx PNPM_HOME ~/.local/share/pnpm
    fish_add_path -g $PNPM_HOME/bin
end

# fnm (Fast Node Manager): expone la versión de node activa
set -l fnm_path ~/.local/share/fnm
if test -x $fnm_path/fnm
    fish_add_path -g $fnm_path
    fnm env --shell fish | source
end

# Homebrew
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
end
