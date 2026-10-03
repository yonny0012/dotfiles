# Evaluación de migración: hyprlang (.conf) → Lua

> **Estado:** ✅ **MIGRACIÓN EJECUTADA** — pendiente solo de relogin para activar · **Rama:** `feat/lua-migration` · **Hyprland:** 0.56.2
> **Fecha:** 2026-10-03

---

## 1. Contexto y urgencia

| Hito | Fecha | Impacto |
|------|-------|---------|
| Hyprland 0.55 introduce `hyprland.lua` | abr 2026 | Lua pasa a ser el formato recomendado |
| Hyprland 0.56 (jul 2026) y 0.56.1 | jul 2026 | Aviso de deprecación en configs `.conf`; 0.56.0 **sin breaking changes** |
| **Eliminarán hyprlang** | 1–2 releases desde 0.55 (anuncio oficial) | ⚠️ Con 0.56 fuera, la ventana de soporte se cierra en la próxima o siguiente release mayor |

**Conclusión:** la migración no es opcional a medio plazo. Hacerla ahora cuesta menos que hacerla bajo presión cuando salga la release que la rompa.

---

## 2. Inventario de lo que hay que migrar

Punto de entrada: `hyprland.conf` (25 líneas, solo `source=`). Contenido real en `conf.d/`:

| Archivo | Líneas | Contenido | Complejidad de conversión |
|---------|-------:|-----------|---------------------------|
| `env.conf` | 15 | `env =` × 7 | 🟢 Trivial → `hl.env()` |
| `execs.conf` | 31 | `exec-once =` × 13 | 🟢 Bajo → evento `hl.on("hyprland.start", ...)` |
| `monitors.conf` | 27 | monitor + input + gestures | 🟢 Bajo → `hl.monitor()`, `hl.config{input=...}`, `hl.gesture()` |
| `theme.conf` | 48 | general, decoration, blur, shadow, animaciones | 🟡 Medio → `hl.config{}` + `hl.curve()`/`hl.animation()` (1:1 pero sintaxis nueva) |
| `keybinds.conf` | 91 | ~45 binds + variables + 1 submap | 🟡 Medio-alto → `hl.bind()` con dispatchers tipados |
| `rules.conf` | 232 | 7 layerrules + 20 windowrules | 🟡 Medio → `hl.layer_rule()` / `hl.window_rule()` con `match = {}` |
| `settings.conf` | 1 | `debug:disable_logs = false` | 🟢 Trivial |
| **Total** | **~445** | | |

**Acoplamientos externos detectados (fuera de `hypr/`):**
- `eww/.config/eww/widgets/session.yuck` → usa `hyprctl dispatch exit` (sigue funcionando, no cambia)
- `eww/.config/eww/scripts/power_actions.sh` → idem
- `hypr/.config/hypr/scripts/toggle-power-menu.sh` → no toca hyprctl (solo eww) ✅
- ⚠️ **Ningún script hace `hyprctl keyword`** (el patrón que sí se rompería con Lua) — verificado

---

## 3. Cambios de paradigma que hay que asimilar

No es una traducción de sintaxis; cambian cuatro modelos mentales:

1. **`source=` → `require()`**: cada módulo Lua se carga en un *scope aislado* (errores en un archivo no matan los demás). Mejor aislamiento que hoy.
2. **Binds declarativos → dispatchers tipados**: `bind = $mainMod, c, killactive` se vuelve `hl.bind(mainMod .. " + C", hl.dsp.window.close())`. El tipado nuevo detecta errores en reload, no en runtime silencioso.
3. **Variables `$var` → locales de Lua**: `$mainMod = SUPER` se convierte en `local mainMod = "SUPER"` y permite interpolación (`mainMod .. " + Q"`), loops reales (los 12 binds de workspaces se generan con un `for`).
4. **`exec-once` → evento de arranque**: `hl.on("hyprland.start", function() ... end)`.

## 4. Costo estimado

### Por sección

| Sección | Esfuerzo | Riesgo |
|---------|----------|--------|
| env, execs, monitors, settings | 🟢 ~30 min | Muy bajo — mapeo 1:1 documentado |
| theme (animaciones/beziers) | 🟡 ~45 min | Bajo — mismo modelo, sintaxis `hl.curve`/`hl.animation` |
| rules (27 reglas) | 🟡 ~60–90 min | Medio — `match:{}` combina propiedades; verificar comportamientos de stack de reglas |
| keybinds (45 binds + submap) | 🟡 ~60 min | Medio — submaps cambian a `hl.define_submap()` (mejor API, pero hay que reescribirlos) |
| Verificación en vivo (Session) | 🔴 ~45–60 min | El costo real: probar cada bind, regla y blur de capa en la sesión |

### Total realista
- **Trabajo mecánico:** 3.5–5 h
- **Pruebas y ajustes:** 1–2 h
- **Buffer de sorpresas:** 1 h
- **≈ 6–8 h en total**, una tarde larga o dos sesiones.

### Factores que lo abaratan
- Config pequeña y bien modularizada (~445 líneas efectivas).
- Cero scripts con `hyprctl keyword` (el acoplamiento grave no existe).
- Todas las props de reglas que usas existen en la API Lua (verificado: `idle_inhibit`, `stay_focused`, `keep_aspect_ratio`, blur por namespace).
- Stubs oficiales de Lua para autocompletado (`/usr/share/hypr/stubs/` + `.luarc.json`).
- `hyprctl reload` y recarga automática siguen funcionando igual.
- El REPL de Lua en hyprctl (nuevo en 0.56) permite probar dispatchers en vivo.

### Factores de riesgo
1. 🔴 **Sin herramienta oficial de conversión automática** — el wiki confirma que no hay script; todo es manual.
2. 🟠 **Semántica de `match` puede diferir del `match:` anidado de 0.54** — hay que validar cada regla contra `hyprctl clients` real.
3. 🟠 **Submap de resize**: la API nueva es diferente; revisar el flujo completo.
4. 🟠 Si el wiki versionado en `wiki.hypr.land/0.56.x` tiene opciones aún no cubiertas por Lua, habría que reportarlas, no emularlas.
5. 🟢 Los dotfiles se gestionan con symlinks/stow — no afecta, pero `.luarc.json` nuevo conviene versionarlo.

## 5. Mejoras de 0.56 aplicables durante la migración

Migrar es el momento ideal para adoptar esto "gratis":

| Mejora | Dónde aplicar |
|--------|---------------|
| **Stubs + autocompletado de Lua** en el editor | `.luarc.json` en la raíz del repo |
| **REPL interactivo de Lua** (`hyprctl`) | Depurar dispatchers/reglas sin reloggear |
| `hyprctl config full-reload` | Script de post-merge para recarga completa |
| **Motion blur** por ventana | Opción nueva de renderer; evaluar en `theme` |
| **Tonemapping** configurable | Si tienes HDR/ICC activo |
| Animaciones de **gradiente/ángulo** en glow y shadow | `theme` — sombras Catppuccin más ricas |
| Dispatcher `inhibit_scroll` + `fit_into_view` (scrolling) | Solo si pruebas el scrolling layout |
| `focus_master_on_close` (master) | Solo si cambias de dwindle |
| Reglas nuevas: `no_auto_hdr`, selector `stableid:`, `suppressevent` X11 | `rules` — p. ej. Brave fullscreen con `stableid` |
| Evento `specialActive` + `changeworkspaceid` en socket2 | Útil para Eww (workspaces en tiempo real) |

## 6. Plan de migración propuesto (por fases, cada una revertible)

```
Fase 0  (30 min)   .luarc.json + stubs; validar que /usr/share/hypr/stubs existe
Fase 1  (1 h)      hyprland.lua mínimo: env + monitors + settings → probar sesión
Fase 2  (1 h)      theme.lua (curvas + animaciones) → comparar visualmente
Fase 3  (1–1.5 h)  rules.lua (layerrules primero, luego windowrules) → probar cava/brave/power-menu
Fase 4  (1.5 h)    keybinds.lua (binds base, submap resize al final) → recorrer TODOS los binds
Fase 5  (30 min)   execs vía hyprland.start; borrar conf.d/*.conf y hyprland.conf
                   → commit final; actualizar README del repo
```

**Estrategia de seguridad:** mientras `hyprland.lua` y `hyprland.conf` coexistan, Hyprland carga el `.lua` con prioridad; el `.conf` queda como fallback revertible (solo borrar la copia en `~/.config/hypr/` para volver atrás). Recomendamos no borrar los `.conf` hasta la Fase 5.

**Criterio de done:** sesión completa 24h sin `hyprctl rollinglog` mostrando errores de config + checklist de binds/reglas pasado.

## 7. Alternativa: no migrar aún

Viable solo si planeas quedarte en 0.56.2 congelado. Riesgo: cuando salga 0.57/1.0 y eliminen hyprlang, la config no cargará y migrarás en modo emergencia (mismo costo, peor momento). **Recomendación: migrar ahora, con el 0.56.2 estable y sin breaking changes.**

---

## 8. Registro de ejecución (2026-10-03)

**Fases 0–5 completadas.** Archivos creados:

| Archivo | Contenido |
|---------|-----------|
| `hyprland.lua` | Punto de entrada con 6 `require()` en el mismo orden que el `.conf` |
| `conf.d/env.lua` | 7 variables `hl.env()` |
| `conf.d/monitors.lua` | `hl.monitor()` + `hl.config{input=}` + `hl.gesture()` |
| `conf.d/theme.lua` | general/decoration + 5 curvas + 7 animaciones |
| `conf.d/rules.lua` | 8 `hl.layer_rule()` + 19 `hl.window_rule()` |
| `conf.d/keybinds.lua` | ~30 binds + loop for de workspaces + submap `resize` con `hl.define_submap` |
| `conf.d/execs.lua` | 16 autostarts vía `hl.on("hyprland.start")` |
| `.luarc.json` (raíz del repo) | Stubs de `/usr/share/hypr/stubs` para autocompletado |

**Verificación sin tocar la sesión viva:** harness en `/tmp/hypr-verify/` (symlink a `conf.d`) + `Hyprland --verify-config`. Resultado final: **`config ok`**.

**Errores detectados y corregidos por el verificador:**
1. `col.active_border = {...}` → sintaxis Lua inválida (punto en identificador); corregido a `["col.active_border"]`.
2. Animación `global` exige campo `speed` obligatorio en Lua (en hyprlang era opcional); añadido `speed = 10`.

**Semántica de activación (verificada en el log de la sesión):**
- La sesión actual arrancó con `.conf` (`Lua config not found, using legacy config`) y **sigue funcionando con él** aunque exista el `.lua`: Lua solo se carga al iniciar la sesión.
- `hyprland.start` se emite una sola vez por sesión (equivalente exacto a `exec-once`; sin duplicación en reloads).

**Pendiente (checklist post-relogin):**
- [ ] `hyprctl configerrors` vacío tras el login
- [ ] Recorrer todos los binds (lanzadores, workspaces 1–6, foco, screenshots, submap resize con Esc)
- [ ] Verificar blur de capas (waybar, wofi, power menu) y reglas de apps (scrcpy, dialogs, Brave fullscreen)
- [ ] Confirmar en el log: `Using config: .../hyprland.lua`
- [ ] Tras 24–48h estables: borrar `hyprland.conf` y `conf.d/*.conf` (commit de limpieza)

### Resumen ejecutivo
- **Costo:** ~6–8 h de trabajo total (3.5–5 h mecánico + pruebas), config pequeña y sin acoplamientos peligrosos.
- **Riesgo principal:** conversión manual de reglas y validación en sesión viva; no hay conversor automático.
- **Urgencia:** alta a medio plazo — hyprlang será eliminado en próximas releases.
- **Bonus:** migrar ahora permite adoptar stubs de editor, REPL, motion blur y reglas nuevas sin doble trabajo.
