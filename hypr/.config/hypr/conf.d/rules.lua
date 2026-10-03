-- ==============================================================================
-- Rules & Blur (Window & Layer rules)
-- Migrado desde rules.conf (Hyprland 0.54+ nested → Lua API)
-- ==============================================================================

-- ====================
-- Layer Rules (Barras, Menus)
-- ====================

hl.layer_rule({
    name = "blur-waybar",
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-eww-dashboard",
    match = { namespace = "eww-dashboard" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "blur-power-menu",
    match = { namespace = "power-menu" },
    blur = true,
    ignore_alpha = 0.2,
})

-- Animación suave tipo fade para el power menu
hl.layer_rule({
    name = "anim-power-menu",
    match = { namespace = "power-menu" },
    animation = "fade",
})

hl.layer_rule({
    name = "blur-wofi",
    match = { namespace = "wofi" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-notifications",
    match = { namespace = "mako" },
    blur = true,
    ignore_alpha = 0.3,
})

hl.layer_rule({
    name = "blur-monitor-sidebar",
    match = { namespace = "monitor-sidebar" },
    blur = true,
    ignore_alpha = 0.3,
})

hl.layer_rule({
    name = "anim-monitor-sidebar",
    match = { namespace = "monitor-sidebar" },
    animation = "fade",
})

-- ════════════════════════════════════════════════════════════════════════
-- WINDOW RULES — Aplicaciones
-- ════════════════════════════════════════════════════════════════════════

-- ── Herramientas del sistema ──────────────────────────────────────────

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
    size = { 700, 450 },
    center = true,
})

hl.window_rule({
    name = "float-blueman",
    match = { class = "blueman-manager" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-nmconnection",
    match = { class = "nm-connection-editor" },
    float = true,
    center = true,
})

-- Teléfono (1080x2244 → ratio ≈ 0.481). Flotante con el aspecto del móvil
-- en vez de ocupar todo el ancho; la altura (700) cabe en el eDP-1 de 768px.
hl.window_rule({
    name = "float-scrcpy",
    match = { class = "^(scrcpy)$" },
    float = true,
    size = { 337, 700 },
    center = true,
    keep_aspect_ratio = true,
})

-- ── Terminal ──────────────────────────────────────────────────────────

hl.window_rule({
    name = "opacity-kitty",
    match = { class = "kitty" },
    opacity = "0.85 1",
})

-- ── Visualizador de audio ─────────────────────────────────────────────

hl.window_rule({
    name = "float-cava",
    match = { class = "ncmpcpp", title = "^(cava)$" },
    float = true,
    opacity = "0.9 0.9",
})

-- ── Navegadores ───────────────────────────────────────────────────────

hl.window_rule({
    name = "no-idle-brave-fullscreen",
    match = { class = "brave-browser", fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- ── Privacidad / Seguridad ────────────────────────────────────────────

hl.window_rule({
    name = "float-tor",
    match = { class = "tor-browser" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-bitwarden",
    match = { title = "^(Bitwarden)$" },
    float = true,
    center = true,
    size = { 400, 600 },
})

-- ── Gestores de archivos y portales ──────────────────────────────────
-- NOTA: title para diálogos que cambian el título tras abrirse

hl.window_rule({
    name = "float-filemanager-dialogs",
    match = {
        class = "^(thunar|xdg-desktop-portal-gtk)$",
        title = "^(Open File|Save File|Abrir|Guardar|All Files|Rename)$",
    },
    float = true,
    center = true,
    size = { 800, 600 },
    opacity = "0.8 0.7",
})

-- ── Editores ──────────────────────────────────────────────────────────

hl.window_rule({
    name = "opacity-vscode",
    match = { class = "code" },
    opacity = "0.75 0.95",
})

-- ── Videollamadas — popups de compartir pantalla ──────────────────────
-- Usa expresiones de posición: monitor_h en lugar de valor hardcodeado

hl.window_rule({
    name = "meet-share-popup",
    match = { title = "^(meet\\.google\\.com is sharing your screen\\.)$" },
    float = true,
    move = "0 (monitor_h-330)",
})

-- ── Música & Monitoreo ────────────────────────────────────────────────

hl.window_rule({
    name = "float-ncmpcpp",
    match = { class = "ncmpcpp" },
    float = true,
    size = { 1000, 600 },
    center = true,
})

hl.window_rule({
    name = "float-missioncenter",
    match = { class = "io.missioncenter.MissionCenter" },
    float = true,
    size = { 800, 600 },
    center = true,
    opacity = "0.9 0.8",
})

-- ── Power Menu (eww) ──────────────────────────────────────────────────
-- La ventana eww del power menu se trata como overlay fullscreen flotante.
-- `stay_focused` evita que pierda el foco al hacer clic en botones internos.
-- `pin` la mantiene visible en todos los workspaces.

hl.window_rule({
    name = "float-power-menu",
    match = { class = "power-menu" },
    float = true,
})

hl.window_rule({
    name = "pin-power-menu",
    match = { class = "power-menu" },
    pin = true,
})

hl.window_rule({
    name = "focus-power-menu",
    match = { class = "power-menu" },
    stay_focused = true,
})

hl.window_rule({
    name = "noborder-power-menu",
    match = { class = "power-menu" },
    rounding = 0,
})
