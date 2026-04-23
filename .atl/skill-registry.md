# Agent Teams Lite — Skill Registry

## Project Standards (auto-resolved)

<!-- These compact rules are injected into context during execution. -->

**Architecture & Stack**:
- OS: Debian (Wayland)
- WM: Hyprland
- Status: Waybar
- UI: Eww
- Terminal: Kitty
- Shell: Fish
- Multiplexer: Zellij
- Manager: GNU Stow

**Core Rules**:
- Strict Modularity: Each app in its own root folder (`~/dotfiles/[package]/.config/`).
- Stow Symlinking: Do not manually copy; use `stow <package>` from the repo root.
- No Secrets: Do not commit API keys or passwords.
- Atomic Commits: One app/change per commit. Use Conventional Commits.
- UI/Eww: Use modular SCSS. Scripts go to `~/.local/bin` or within the package.

## Loaded Skills

| Skill | Trigger Context | Source |
|-------|-----------------|--------|
| branch-pr | Creating a pull request, opening a PR | global |
| go-testing | Go testing patterns, Bubbletea | global |
| issue-creation | Creating GitHub issue, reporting bug | global |
| judgment-day | Dual adversarial review | global |
| skill-creator | Creating new AI skills | global |
| skill-registry | Updating or generating skill registry | global |

## Known Project Conventions

- `AGENT.md` (Main agent configuration and rules)
