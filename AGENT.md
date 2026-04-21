# 🤖 System Configuration Agent Specification (AGENT.md)

## 📋 Perfil del Sistema

Este repositorio gestiona los archivos de configuración (dotfiles) para un entorno de escritorio moderno basado en Wayland sobre Debian GNU/Linux.

- **OS:** Debian (Stable/Testing/Sid - especificar según corresponda)
- **Window Manager:** Hyprland (Wayland)
- **Barra de Estado:** Waybar
- **Widgets/UI:** Eww (Elkowar's Wacky Widgets)
- **Terminal:** Kitty
- **Shell:** Fish
- **Multiplexor:** Zellij
- **Gestor de Dotfiles:** GNU Stow

---

## 🏗️ Arquitectura de Repositorio

El repositorio utiliza una estructura modular compatible con **GNU Stow**.

```text
~/dotfiles/
├── [paquete]/          # Nombre del programa (ej. hypr, kitty)
│   └── .config/        # Refleja la ruta relativa al $HOME
│       └── [programa]/
│           └── config  # Archivo real
```

## Reglas de Organización

1. **Modularidad Estricta**: Cada aplicación debe estar en su propia carpeta raíz en el repositorio.
2. **Symlinking**: No se copian archivos manualmente; se usa `stow <paquete>` desde la raíz del repo.
3. **No Secretos**: Queda prohibido subir llaves API, contraseñas o tokens. Usar archivos .env o archivos cargados externamente ignorados por git

---

## 🛠️ Estándares de Configuración (SDD - Software Development Design)

### 1. Hyprland

**Segmentación**: El archivo hyprland.conf debe ser un cargador principal.

**Estructura**: Usar `source = ~/.config/hypr/conf.d/archivo.conf`.

**Categorías**: Dividir en `monitors.conf`, `keybinds.conf`, `rules.conf`, y `execs.conf`.

### 2. Fish Shell

**Configuración**: Evitar un config.fish gigante.

**Plugins**: Gestionados preferiblemente por Fisher.

**Lógica**: Funciones pesadas en `functions/*.fish, alias y variables en conf.d/*.fish`.

### 3. Waybar & Eww

**Estilo**: CSS modular. Separar variables de colores (paleta) de la estructura de diseño.

**Scripts**: Los scripts de soporte para widgets deben residir en `~/.local/bin` o dentro de la carpeta del paquete en el repo.

## 4. Zellij

**Layouts**: Definir layouts específicos para desarrollo (ej. dev.kdl) que integren Kitty + Fish.

---

## 🔄 Flujo de Trabajo y Mantenimiento

### Protocolo de Modificación

**Análisis**: Antes de editar, verificar dependencias (ej. si un cambio en Waybar requiere un script nuevo).

**Atomicidad**: Un cambio, un commit. No mezclar cambios de Kitty con cambios de Hyprland.

**Validación**:

- **Hyprland**: `hyprctl reload`
- **Waybar**: `killall waybar && waybar` &
- **Fish**: `source ~/.config/fish/config.fish`

### Formato de Commits (Conventional Commits)

- **feat(scope)**: Nueva funcionalidad o configuración.
- **fix(scope)**: Corrección de un error o bind roto.
- **style(scope)**: Cambios estéticos (colores, padding).
- **refactor(scope)**: Reorganización de archivos sin cambiar funcionalidad.

## 🔍 Instrucciones para el Asistente (OpenCode)

Al sugerir cambios, el asistente debe:

1. **Respetar la jerarquía de Stow**: Siempre proponer la ruta dentro de `~/dotfiles/[paquete]/.config/...`.
2. **Prevenir Breaking Changes**: Avisar si una configuración depende de una versión específica de un paquete que podría ser demasiado nueva para los repositorios de Debian Stable.
3. **Documentar**: Incluir comentarios breves en los archivos de configuración explicando el propósito de reglas complejas.

## Herramientas

### **MCP**

1. **engram**: memoria persistenete de contexto, lee y escribe
2. **Context7**: documentacion actualizada. consulta para cualquier libreria, herramienta o framework
