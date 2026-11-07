# 🎮 Gaming en Debian testing (Intel UHD 620)

Guía del setup para correr juegos de **Windows** sobre Debian testing con
Hyprland/Wayland, sin degradar el rendimiento del entorno de desarrollo.

---

## 📊 Punto de partida (hardware real de esta máquina)

| Componente | Valor | Consecuencia |
|------------|-------|--------------|
| CPU | Intel i5-8250U — 4c/8t, 15 W | CPU e iGPU comparten un presupuesto de energía de 15 W |
| GPU | Intel UHD Graphics 620 (KBL GT2), 1.15 GHz | iGPU, sin memoria dedicada; **12 GiB de RAM compartida** |
| RAM | 11 GiB + 11 GiB swap | Sin margen: un juego + IDE abiertos pueden tocar swap |
| Pantalla | eDP-1 1366x768 @ 60 Hz | No hay margen para AA/upscaling nativo: todo lo pesado hay que escalarlo |
| Mesa | 26.1.6 + Vulkan ANV | Driver maduro; OpenGL 4.6 y Vulkan 1.4 disponibles |
| Kernel | 7.2.x, `i915`, `vm.max_map_count=1048576` | Requisito de Proton ya cumplido de fábrica |

> **Expectativa honesta:** esta iGPU corre bien indies, 2D, emulación, e-sports
> ligeros y títulos de 2015-2018 en bajo. Un AAA de 2023+ no entra en 15 W de
> iGPU con 15 W de CPU, ni en Linux ni en Windows. Lo que sigue exprime lo que
> hay; no lo convierte en otra máquina.

---

## 📦 Paquetes instalados y por qué

Todo desde **testing/main**, más Flathub para Heroic y el repo oficial de Valve
para Steam (motivo abajo).

| Paquete | Rol |
|---------|-----|
| `i386` (multiarch) | **Sin esto no hay Steam.** La mayoría de juegos de Windows son binarios de 32 bits y sin `dpkg --add-architecture i386` el cliente no resuelve ninguna dependencia. |
| Steam | Ver la nota siguiente: el paquete de Debian no está disponible hoy en testing, así que se usa el `.deb` oficial de Valve (`steam-launcher`), que trae el Steam Linux Runtime y Proton. |
| `steam-devices` | Reglas udev de mandos (Xbox, DualSense, Switch Pro). Sin ellas Steam no ve el gamepad. |
| `gamemode` | Perfil de rendimiento **acotado al proceso del juego**. Ver abajo. |
| `mangohud` + `goverlay` | OSD de fps/frametimes y editor gráfico de la config. |
| `vkbasalt` | Post-proceso Vulkan (CAS, SMAA, FXAA). Útil para recuperar nitidez cuando se baja la resolución. |
| `vulkan-tools` + `mesa-utils` | `vulkaninfo` / `glxinfo` para verificar que la iGPU expone Vulkan. |
| `earlyoom` | Mata el proceso más gordo antes de que el OOM killer congele la sesión. Protege tanto una partida como un build. |
| `mesa-vulkan-drivers:i386`, `libgl1-mesa-dri:i386`, `libvulkan1:i386`, `mangohud:i386`, `libgamemode*:i386` | Las mismas piezas para los juegos de 32 bits. Es el error clásico: `vulkaninfo` anda y el juego de 32 bits no arranca. |
| Heroic (Flatpak) | Epic/GOG. **No está empaquetado en Debian**; Flathub es la vía oficial. |

### ⚠️ Por qué Steam viene del repo de Valve

`steam-installer` **no tiene binario publicado en testing**: existe la fuente
(`1:1.0.0.87~ds-3`, visible en `apt-cache madison`), pero el índice
`binary-amd64` e `binary-i386` de testing no lo contienen, y en `stable` el
paquete vive en `contrib`, componente que esta instalación no habilita
(`main non-free-firmware`). Resultado: `apt install steam-installer` falla.

El script resuelve esto en dos tiempos:

1. Si algún día vuelve el binario a testing, instala el paquete de Debian.
2. Si no, agrega el **repo oficial de Valve** con la clave verificada por
   huella (`BA18 16EF 8E75 005F CF5E 27A1 F24A EA9F B054 98B7`) e instala
   `steam-launcher`, que es el método que Valve documenta para Debian.

Queda como archivo deb822 en `/etc/apt/sources.list.d/steam.sources`, con el
mismo formato que el resto de las fuentes del sistema. Si preferís no tener un
repo de terceros, la alternativa es Flatpak (`com.valvesoftware.Steam`), con
peor integración de mandos y rutas.

### Lo que **no** se instaló, y por qué

| Descartado | Motivo |
|-----------|--------|
| `wine` / `wine-staging` del sistema | `wine` **no figura en testing** ahora mismo, y Proton/Wine-GE ya traen su propio Wine versionado por juego. Un wine de sistema solo agrega conflictos de prefijo. |
| `lutris` | No está en testing. Si se necesita más adelante: Flatpak. |
| `gamescope` | **No está en testing.** Se puede construir, pero en una iGPU de 15 W el compositor anidado cuesta más de lo que aporta; FSR interno de Proton hace el mismo trabajo sin capa extra. |
| `scx-scheds`, `ananicy-cpp` | No están en testing. Cambiar el scheduler del sistema afecta a todos los procesos, incluido el desarrollo. |
| Kernel custom (XanMod/CachyOS) | Ganancia marginal en Kaby Lake y pérdida de soporte de seguridad de Debian. |

---

## ⚙️ Lo importante: no tocar el rendimiento de desarrollo

La regla del setup de gaming es **todo opt-in por proceso**: `setup-gaming.sh`
no agrega nada al arranque del sistema ni a `/etc/sysctl.d`. (El ajuste general
de memoria, red y zram es aparte: lo aplica el paso 8 de `setup-system.sh` y
está documentado en la sección "Rendimiento del sistema" del README.)

- **GameMode solo actúa con `gamemoderun`.** Sin ese prefijo, el gobernador,
  el nice y la prioridad de I/O quedan intactos para IDEs, compiladores,
  contenedores y tests.
- **No se fuerza `performance` en la CPU.** En un chip de 15 W con iGPU, fijar
  la CPU a tope le quita watts a la gráfica y provoca throttling: menos fps y
  más calor. `desiredgov=powersave` deja trabajar a HWP, que ya sube a turbo
  bajo carga. (En un desktop con GPU dedicada sí conviene `performance`.)
- **El gaming no toca `vm.swappiness`, THP, mitigaciones ni el governor
  global.** Son los ajustes típicos de "gaming tuning" que en un 15 W sólo
  empeoran la latencia de compilación y de contenedores. Los valores que sí
  tiene el sistema (`vm.swappiness=100` por zram, THP en `madvise`) vienen del
  setup general y no se cambian para jugar.
- **`vm.max_map_count` ya está en 1048576**, el valor que pide Proton. No hay
  nada que cambiar.

---

## 🚀 Uso diario

### Opciones de lanzamiento en Steam

Para cada juego → Propiedades → Opciones de lanzamiento:

```bash
gamemoderun mangohud %command%
```

Con FSR interno de Proton (recomendado en esta iGPU para títulos 3D). Bajar la
resolución interna y dejar que Proton escale:

```bash
WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=2 gamemoderun mangohud %command%
```

`FSR_STRENGTH` va de 0 (más nítido) a 5 (más rendimiento); 2 es el equilibrio.
Desde Fish, `opciones-fsr 3` imprime la cadena ya armada.

> ⚠️ **FSR no funciona junto a `PROTON_ENABLE_WAYLAND=1`.** El driver Wayland
> experimental de Wine desactiva el parche de fullscreen FSR
> ([proton-ge-custom#409](https://github.com/GloriousEggroll/proton-ge-custom/issues/409)).
> Para esta máquina conviene quedarse en XWayland, que es el default.

### Variantes útiles

| Objetivo | Opciones |
|----------|----------|
| Máxima nitidez a 768p nativo | `gamemoderun mangohud %command%` |
| Juego 3D que no llega a 30 fps | `WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=3 gamemoderun mangohud %command%` |
| Juego OpenGL (no Vulkan) | `mesa_glthread=true gamemoderun mangohud %command%` |
| Diagnóstico de stutter | `DXVK_HUD=compiler,memory gamemoderun mangohud %command%` |
| Forzar una versión de Proton | Propiedades → Compatibilidad → forzar `Proton Experimental` o GE-Proton |

### Fuera de Steam

```fish
gamelog wine ~/Juegos/algo.exe      # gamemode + OSD + WINEDEBUG silenciado
```

---

## 🔍 Verificación

```bash
# De dónde salió Steam (Debian o Valve)
grep -r URIs /etc/apt/sources.list.d/steam.sources 2>/dev/null || echo "Steam desde Debian"

# Vulkan ve la iGPU con ANV
vulkaninfo --summary | head -20

# El driver de 32 bits también está (esto es lo que rompe juegos viejos)
file /usr/lib/i386-linux-gnu/libvulkan.so.1

# MangoHud y GameMode cargan
gamemoded -t

# MangoHud overlaid en un proceso cualquiera
mangohud glxgears
```

En el juego: **Shift_R+F12** muestra/oculta el OSD. Si `gamemode` aparece en el
OSD, el prefijo está activo.

---

## 🧯 Problemas típicos

| Síntoma | Causa / arreglo |
|---------|-----------------|
| `steam-installer` sin candidato | Falta `dpkg --add-architecture i386` + `apt update`, o el binario no está en testing (el script cae al repo de Valve). |
| Juego de 32 bits no arranca, `vulkaninfo` sí anda | Faltan `mesa-vulkan-drivers:i386` / `libvulkan1:i386`. |
| Steam no detecta el mando | Falta `steam-devices` (udev) → reinstalar y reconectar. |
| Stutter que baja con el tiempo de juego | Caché de shaders recompilando: verificar `MESA_SHADER_CACHE_MAX_SIZE` (8G) y dejar el juego en el mismo Proton. |
| Fps bajos y CPU al 100 % con GPU al 30 % | Cuello de botella de CPU o `DXVK` compilando; probar `DXVK_HUD=compiler`. |
| Todo se congela y hay que reiniciar | `earlyoom` debería prevenirlo; si pasa igual, cerrar el IDE antes de jugar (11 GiB no dan para ambos). |
| Pantalla se bloquea jugando | Regla `game-idle-inhibit` en `rules.lua` (match `steam_app_*`); aplica para juegos lanzados desde Steam. |
| FSR activo pero imagen sin cambios | El juego debe estar en **pantalla completa exclusiva**, no ventana ni borderless. |

---

## 📚 Referencias

- [Debian Wiki — Steam](https://wiki.debian.org/Steam) — multiarch i386, `steam-installer` y `steam-devices`.
- [Repo oficial de Steam para Debian/Ubuntu](https://repo.steampowered.com/steam/) — paquete `steam-launcher` y su clave GPG.
- [FeralInteractive/gamemode — `gamemode.ini` de ejemplo](https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini) — claves `desiredgov`, `igpu_desiredgov`, `disable_splitlock`.
- [MangoHud — `MangoHud.conf` de referencia](https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf) — todas las claves del OSD.
- [ValveSoftware/Proton](https://github.com/ValveSoftware/Proton) — variables de entorno y estado de `PROTON_ENABLE_WAYLAND`.
- [proton-ge-custom#409](https://github.com/GloriousEggroll/proton-ge-custom/issues/409) — incompatibilidad FSR ↔ driver Wayland.
- [ProtonDB — Improving performance](https://www.protondb.com/help/improving-performance) — variables por tipo de GPU.
- [Arch Wiki — Steam](https://wiki.archlinux.org/title/Steam) / [Gaming](https://wiki.archlinux.org/title/Gaming) — referencia cruzada de dependencias de 32 bits, aplicable fuera de Arch.

---

## 🗂️ Archivos de este repo

```text
scripts/setup-gaming.sh            # instalación (multiarch, Steam, gamemode, Heroic)
gamemode/.config/gamemode.ini      # perfil acotado a la sesión de juego
mangohud/.config/MangoHud/MangoHud.conf  # OSD para 1366x768
fish/.config/fish/conf.d/30-gaming.fish  # MESA_SHADER_CACHE_MAX_SIZE, gamelog, opciones-fsr
hypr/.config/hypr/conf.d/rules.lua       # regla game-idle-inhibit
```

Desplegar:

```bash
cd ~/dotfiles
stow gamemode mangohud fish hypr
```
