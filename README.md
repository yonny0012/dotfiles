# 🐧 Dotfiles

> Configuración personal de entorno de escritorio moderno sobre **Debian GNU/Linux** + **Wayland**.

Un repositorio modular, minimalista y glassmórfico gestionado con **GNU Stow**.

---

## 📸 Preview

![Desktop Preview](https://raw.githubusercontent.com/yonny0012/dotfiles/main/.github/preview.png)

---

## 🧰 Stack Tecnológico

| Tecnología | Descripción |
|------------|-------------|
| ![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white) | Sistema operativo base |
| ![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black) | Window manager compositor (Wayland) |
| ![Waybar](https://img.shields.io/badge/Waybar-313131?style=for-the-badge&logo=wayland&logoColor=white) | Barra de estado personalizable |
| ![Wofi](https://img.shields.io/badge/Wofi-FF4785?style=for-the-badge&logo=rocket&logoColor=white) | Lanzador de aplicaciones (drun/menu) |
| ![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white) | Editor de texto modal |
| ![Fish](https://img.shields.io/badge/Fish-37474F?style=for-the-badge&logo=fishshell&logoColor=white) | Shell interactiva amigable |
| ![Kitty](https://img.shields.io/badge/Kitty-000000?style=for-the-badge&logo=kitty&logoColor=white) | Terminal GPU-acelerada |
| ![Zellij](https://img.shields.io/badge/Zellij-5B5BD6?style=for-the-badge&logo=tmux&logoColor=white) | Multiplexor de terminal |
| ![Starship](https://img.shields.io/badge/Starship-DD0B78?style=for-the-badge&logo=starship&logoColor=white) | Prompt minimalista y rápido |

---

## 🏗️ Arquitectura del Repositorio

```text
~/dotfiles/
├── hypr/               # Hyprland (window manager)
│   └── .config/hypr/
├── waybar/             # Barra de estado
│   └── .config/waybar/
├── wofi/               # Lanzador de aplicaciones
│   └── .config/wofi/
├── nvim/               # Neovim
│   └── .config/nvim/
├── fish/               # Fish shell
│   └── .config/fish/
├── kitty/              # Terminal
│   └── .config/kitty/
├── zellij/             # Multiplexor
│   └── .config/zellij/
├── starship/           # Prompt
│   └── .config/
└── README.md           # Este archivo
```

> **Regla de oro:** cada aplicación en su propio paquete Stow. Sin secretos en el repo.

---

## 🚀 Instalación Rápida

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Instalar dependencias (Debian)

```bash
sudo apt update
sudo apt install -y stow hyprland waybar wofi neovim fish kitty zellij starship
```

### 3. Desplegar configuraciones con Stow

```bash
# Desplegar todo
stow */

# O desplegar paquetes individuales
stow hypr waybar wofi nvim fish kitty zellij starship
```

### 4. Cambiar shell por defecto a Fish

```bash
chsh -s $(which fish)
```

---

## 🔄 Flujo de Trabajo

### Modificar configuraciones

```bash
cd ~/dotfiles
# Edita el archivo deseado, por ejemplo:
nvim hypr/.config/hypr/hyprland.conf
```

### Aplicar cambios

| Paquete | Comando de recarga |
|---------|-------------------|
| Hyprland | `hyprctl reload` |
| Waybar | `killall waybar && waybar &` |
| Wofi | Cerrar y reabrir (no tiene hot-reload) |
| Fish | `source ~/.config/fish/config.fish` |
| Kitty | `killall kitty` (o recargar prefs) |
| Zellij | Recargar sesión |

### Commits (Conventional Commits)

```bash
git add hypr/.config/hypr/conf.d/monitors.conf
git commit -m "feat(hypr): añade configuración de monitores dual"
```

Formatos soportados:
- `feat(scope)` — nueva funcionalidad
- `fix(scope)` — corrección de errores
- `style(scope)` — cambios estéticos (colores, padding)
- `refactor(scope)` — reorganización sin cambio de funcionalidad

---

## 🎨 Características Visuales

- **Glassmorphism**: transparencias con blur gestionadas por el compositor
- **Paleta coherente**: acentos azules sobre base oscura neutra
- **Iconos Nerd Font**: integración completa en terminal y launchers
- **Minimalismo funcional**: solo información relevante en la UI

---

## 📋 Requisitos

| Requisito | Versión mínima |
|-----------|---------------|
| Debian | Stable/Testing/Sid |
| Hyprland | 0.35+ |
| Waybar | 0.9.24+ |
| Wofi | 1.4+ |
| Neovim | 0.9+ |
| Fish | 3.6+ |
| Kitty | 0.30+ |
| Zellij | 0.39+ |
| Starship | 1.17+ |

---

## 📝 Licencia

[MIT](LICENSE) © tu-nombre

---

> *"La simplicidad es la máxima sofisticación."* — Leonardo da Vinci
