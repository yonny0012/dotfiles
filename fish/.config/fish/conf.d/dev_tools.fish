# ==============================================================================
# Manual Tool Paths (Node, pnpm, Rust, fnm, etc.)
# ==============================================================================

# OpenCode / Agent Teams Lite
fish_add_path ~/.opencode/bin

# pnpm
set -gx PNPM_HOME "/home/devshw/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# fnm (Fast Node Manager)
set FNM_PATH "$HOME/.local/share/fnm"
if test -d "$FNM_PATH"
  set PATH "$FNM_PATH" $PATH
  fnm env --shell fish | source
end

# Rust / Cargo
if test -f "$HOME/.cargo/env.fish"
  source "$HOME/.cargo/env.fish"
end