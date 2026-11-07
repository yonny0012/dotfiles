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
| ![Eww](https://img.shields.io/badge/Eww-58E1FF?style=for-the-badge&logo=rust&logoColor=black) | Dashboard, power-menu y monitor-sidebar (Elkowar's Wacky Widgets) |
| ![MPD](https://img.shields.io/badge/MPD-1DB954?style=for-the-badge&logo=musicbrainz&logoColor=white) | Reproductor de música (daemon) |
| ![Btop](https://img.shields.io/badge/Btop-181825?style=for-the-badge&logo=htop&logoColor=white) | Monitor de recursos del sistema |
| ![Cava](https://img.shields.io/badge/Cava-EBA0AC?style=for-the-badge&logo=audiomack&logoColor=black) | Visualizador de audio en terminal |
| ![Hyprlock](https://img.shields.io/badge/Hyprlock-89DCEB?style=for-the-badge&logo=hyprland&logoColor=black) | Pantalla de bloqueo |
| ![Regreet](https://img.shields.io/badge/ReGreet-A6E3A1?style=for-the-badge&logo=gnome&logoColor=black) | Greeter gráfico (greetd) |

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
├── gamemode/           # Perfil de rendimiento para juegos
├── mangohud/           # OSD de fps/frametimes
├── GAMING.md           # Guía de gaming (Steam/Proton, referencias)
├── scripts/            # Setup del sistema (requiere sudo) — no es paquete Stow
│   ├── setup-system.sh # Dependencias, eww/waybar desde git y rendimiento
│   └── install-ui-assets.sh # Greeter de LightDM y fondo
├── system/             # Archivos de /etc — no es paquete Stow
│   └── etc/            # lightdm, sysctl, earlyoom, THP, BBR (se copian con los scripts)
└── README.md           # Este archivo
```

> **Regla de oro:** cada aplicación en su propio paquete Stow. Sin secretos en el repo.

> **`~` vs `/etc`:** los paquetes Stow solo contienen rutas relativas a `$HOME`.
> Lo que va en `/etc` vive en `system/etc/` con la misma ruta que tendrá en el
> sistema, y los scripts lo **copian** (`install -Dm644`), no lo enlazan: `$HOME`
> es `700` y los servicios del sistema no pueden leerlo, y un enlace dejaría
> configuración de root editable por el usuario.

> 🎮 **Gaming:** Steam/Proton y Heroic sobre esta base → ver [`GAMING.md`](GAMING.md).

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
sudo apt install -y stow hyprland waybar wofi neovim fish kitty zellij starship \
  eww hyprlock hypridle sway-notification-center cliphist udiskie btop mpd mpc ncmpcpp cava
```

> **Nota:** `eww` no está empaquetado en los repos de Debian; se recomienda compilarlo
> con `cargo install eww` (requiere Rust vía `rustup`). Verificá con `eww --version`
> que tu build use una versión reciente de `grass` (el compilador SCSS interno);
> versiones antiguas no resuelven `rgba($variable, $alpha)`, por eso este repo
> usa siempre valores `rgb`/`rgba` explícitos en los `.scss` de eww.

### 3. Desplegar configuraciones con Stow

```bash
# Desplegar todo (excepto scripts/ y system/, que no van en $HOME)
stow $(ls -d */ | grep -Ev '^(scripts|system)/$')

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

## 🛠️ Hyprland Keybind Troubleshooting

Si `Super+W` o `Super+T` tardan demasiado (por ejemplo ~25s), validá por capas:

1. **Bind activo en Hyprland**
   ```bash
   hyprctl binds
   ```

2. **Contexto Wayland de la sesión**
   ```bash
   echo "$WAYLAND_DISPLAY"
   echo "$XDG_CURRENT_DESKTOP"
   ```

3. **Logs recientes de usuario (DBus/portal/runtime)**
   ```bash
   journalctl --user -n 50
   ```

4. **Aislar app vs keybind**
   ```bash
   eww open --toggle dashboard
   kitty
   ```

### Nota importante sobre DBus/Portal en Wayland

En esta configuración ya se importa entorno Wayland al iniciar Hyprland:

```conf
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = eww daemon
```

Si persiste un delay largo, suele ser conflicto de portales (`xdg-desktop-portal-gnome`/`kde` junto a Hyprland).

Opciones recomendadas:
- dejar sólo `xdg-desktop-portal-hyprland` como backend principal, o
- reiniciar portales manualmente en sesión activa:

```bash
killall -q xdg-desktop-portal-hyprland xdg-desktop-portal-gnome xdg-desktop-portal-kde xdg-desktop-portal
# En Debian, el binario puede estar en /usr/lib o /usr/libexec según paquete/versión.
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
```

---

## ⚡ Rendimiento del sistema

Ajustes para un portátil con poca RAM (i5-8250U, 12 GB, SSD ext4, zram). Los
aplica el paso `[8/8]` de `scripts/setup-system.sh`; los archivos están en
`system/etc/` y se copian a `/etc`.

```bash
bash ~/dotfiles/scripts/setup-system.sh   # completo
```

### Paquetes

| Paquete | Para qué | Configuración | Documentación |
|---------|----------|---------------|---------------|
| `zram-tools` | Swap comprimida en RAM, prioridad sobre la swap en disco | `/etc/default/zramswap` → `ALGO=zstd`, `PERCENT=50` | [Kernel: zram](https://docs.kernel.org/admin-guide/blockdev/zram.html) · [Debian](https://packages.debian.org/sid/zram-tools) · [ArchWiki](https://wiki.archlinux.org/title/Zram) |
| `earlyoom` | Cierra el proceso más pesado antes de que el sistema se congele | `/etc/default/earlyoom` | [rfjakob/earlyoom](https://github.com/rfjakob/earlyoom) |
| `thermald` | Control térmico de Intel: limita antes de llegar al throttling brusco | por defecto | [intel/thermal_daemon](https://github.com/intel/thermal_daemon) |
| `irqbalance` | Reparte las interrupciones entre los 8 hilos | por defecto | [Irqbalance/irqbalance](https://github.com/Irqbalance/irqbalance) |

### Parámetros del kernel (`/etc/sysctl.d/99-performance.conf`)

| Parámetro | Valor | Por qué |
|-----------|-------|---------|
| `vm.swappiness` | `100` | zram es el primer nivel de swap: comprimir en RAM es más barato que descartar caché y releer del disco |
| `vm.page-cluster` | `0` | zram no tiene coste de búsqueda; leer de a una página reduce latencia |
| `vm.vfs_cache_pressure` | `50` | Retiene más metadatos del sistema de archivos en caché |
| `vm.dirty_ratio` / `vm.dirty_background_ratio` | `10` / `5` | Escrituras más pequeñas y frecuentes, sin bloqueos largos de I/O |
| `net.core.default_qdisc` + `net.ipv4.tcp_congestion_control` | `fq` + `bbr` | Mejor rendimiento en redes reales ([google/bbr](https://github.com/google/bbr)) |
| `net.ipv4.tcp_fastopen` | `3` | Fast Open como cliente y servidor |
| `kernel.nmi_watchdog` | `0` | Libera un contador de rendimiento; innecesario en escritorio |

Documentación: [vm](https://docs.kernel.org/admin-guide/sysctl/vm.html) ·
[red (ip-sysctl)](https://docs.kernel.org/networking/ip-sysctl.html) ·
[kernel](https://docs.kernel.org/admin-guide/sysctl/kernel.html).

### Otros ajustes

| Ajuste | Archivo | Documentación |
|--------|---------|---------------|
| Transparent Huge Pages en `madvise` (evita picos de latencia de `always`) | `/etc/tmpfiles.d/thp-madvise.conf` | [Kernel: THP](https://docs.kernel.org/admin-guide/mm/transhuge.html) |
| Módulo `tcp_bbr` cargado al arranque | `/etc/modules-load.d/bbr.conf` | [Kernel: ip-sysctl](https://docs.kernel.org/networking/ip-sysctl.html) |
| `noatime` en `/` (sin escritura por cada lectura) | `/etc/fstab` | [Kernel: ext4](https://docs.kernel.org/admin-guide/ext4.html) · [ArchWiki: fstab](https://wiki.archlinux.org/title/Fstab) |
| Sin arranque automático: ModemManager, avahi, Odoo, Docker/containerd | `systemctl disable` | — |

Docker y Odoo se arrancan cuando hacen falta: `sudo systemctl start docker` / `sudo systemctl start odoo`.

Guía general: [ArchWiki: Improving performance](https://wiki.archlinux.org/title/Improving_performance).

### Verificar

```bash
/usr/sbin/sysctl vm.swappiness vm.page-cluster net.ipv4.tcp_congestion_control
cat /sys/kernel/mm/transparent_hugepage/enabled   # [madvise]
findmnt -no OPTIONS /                             # noatime
cat /sys/block/zram0/comp_algorithm               # [zstd] tras reiniciar
systemctl is-active earlyoom thermald irqbalance
```

### Notas

- **earlyoom:** systemd separa `$EARLYOOM_ARGS` por espacios y pasa las comillas
  literalmente, así que las regex de `--avoid`/`--prefer` van sin comillas ni espacios.
- **zram:** el cambio de algoritmo aplica al reiniciar; reiniciar `zramswap` con
  swap en uso puede congelar el equipo.
- **`apt-get update` falla:** un repositorio que no publica la suite pedida
  rompe todo el update (y el script, por `set -e`). Ejemplo: OpenVPN3 no publica
  `forky`; usar `Suites: trixie` en `/etc/apt/sources.list.d/openvpn3.sources`.

---

## 📝 Licencia

[MIT](LICENSE) © tu-nombre

---

> *"La simplicidad es la máxima sofisticación."* — Leonardo da Vinci
