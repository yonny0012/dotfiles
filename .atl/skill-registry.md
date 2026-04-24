<!--
---
timestamp: 2026-04-24 20:26:06
project: dotfiles
---
-->
# Skill Registry

This registry provides a consolidated view of the AI agent skills and project conventions active in this repository. It is automatically generated and should not be edited manually.

## Active Skills

The following skills are available to agents working in this project. They provide specialized instructions, patterns, and access to tools for specific tasks.

| Skill | Description |
|---|---|
| `dotfiles-best-practices` | Provides reference knowledge about modern CLI tools, shell optimization patterns, and dotfiles security best practices. Make sure to use this skill whenever the user asks about shell patterns, modern tool alternatives (eza, bat, fd, ripgrep), zsh optimization, or dotfiles conventions. Also loaded automatically by the dotfiles-optimizer skill. |
| `branch-pr` | PR creation workflow for Agent Teams Lite following the issue-first enforcement system. Trigger: When creating a pull request, opening a PR, or preparing changes for review. |
| `go-testing` | Go testing patterns for Gentleman.Dots, including Bubbletea TUI testing. Trigger: When writing Go tests, using teatest, or adding test coverage. |
| `issue-creation` | Issue creation workflow for Agent Teams Lite following the issue-first enforcement system. Trigger: When creating a GitHub issue, reporting a bug, or requesting a feature. |
| `judgment-day` | Parallel adversarial review protocol that launches two independent blind judge sub-agents simultaneously to review the same target, synthesizes their findings, applies fixes, and re-judges until both pass or escalates after 2 iterations. Trigger: When user says "judgment day", "judgment-day", "review adversarial", "dual review", "doble review", "juzgar", "que lo juzguen". |
| `skill-creator` | Creates new AI agent skills following the Agent Skills spec. Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI. |
| `ui-ux-pro-max` | UI/UX design intelligence with searchable database |

## Project Conventions

The following documents define the established engineering conventions, architectural patterns, and agent behaviors for this project. Agents MUST adhere to these rules.

- **Source**: `AGENT.md`

### Compact Rules (for agent injection)

#### from `AGENT.md`:
- **Repo Architecture**: Use GNU Stow structure: `[package]/.config/[program]/config`.
- **Modularity**: Each application must be in its own root folder.
- **Symlinking**: Use `stow <package>`; do not copy files manually.
- **No Secrets**: Do not commit API keys, passwords, or tokens.
- **Hyprland Config**: Main `hyprland.conf` is a loader. Use `source =` for modular files (`monitors.conf`, `keybinds.conf`, etc.).
- **Fish Shell Config**: Avoid a monolithic `config.fish`. Use `functions/*.fish` and `conf.d/*.fish`.
- **Waybar & Eww Style**: Use modular CSS, separating color variables from layout.
- **Commit Format**: Use Conventional Commits (`feat(scope):`, `fix(scope):`, etc.).
- **Agent Behavior**: Respect Stow hierarchy, warn about breaking changes related to Debian package versions, and document complex rules with comments.
