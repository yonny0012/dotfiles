-- ==============================================================================
-- Atajos y Funciones (Keybinds)
-- ==============================================================================

-- Variables generales
local mainMod      = "SUPER"
local terminal     = "kitty"
local fileManager  = "thunar"
local menu         = "wofi"
local browser      = "brave-browser"

-- --- [ Lanzadores Básicos ] ---
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu .. " --show drun"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(terminal .. " --class ncmpcpp -e cava &"))

-- --- [ Dashboard y Controles ] ---
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("eww open --toggle dashboard"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-power-menu.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- --- [ Enfoque de Ventanas ] ---
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- --- [ Workspaces ] ---
-- Generado con loop (ventaja de Lua: antes eran 12 binds manuales)
for i = 1, 6 do
    hl.bind(mainMod .. " + " .. i,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,  hl.dsp.window.move({ workspace = i }))
end

-- --- [ Control de Medios ] ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
hl.bind("XF86PowerOff",         hl.dsp.exec_cmd("hyprlock"))

-- ── Screenshots ──────────────────────────────────────────────────────────────
-- Pantalla completa: guarda + copia al portapapeles
hl.bind("PRINT", hl.dsp.exec_cmd("grim - | wl-copy && grim $(xdg-user-dir PICTURES)/screenshots/$(date +'%s_screenshot.png')"))
-- Área seleccionada: guarda + copia (slurp se ejecuta una sola vez con variable)
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("SRC=$(slurp) && grim -g \"$SRC\" - | wl-copy && grim -g \"$SRC\" $(xdg-user-dir PICTURES)/screenshots/$(date +'%s_area.png')"))

-- Historial del portapapeles visual (Estilo Win + V)
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- ── Movimientos de ventanas (mouse) ─────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Redimensionado con teclado (submap) ─────────────────────────────────────
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right", function()
        hl.dispatch(hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
    end, { repeating = true })
    hl.bind("left", function()
        hl.dispatch(hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
    end, { repeating = true })
    hl.bind("up", function()
        hl.dispatch(hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
    end, { repeating = true })
    hl.bind("down", function()
        hl.dispatch(hl.dsp.window.resize({ x = 0, y = 10, relative = true }))
    end, { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)
