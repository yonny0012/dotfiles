-- ==============================================================================
-- Variables de Entorno Específicas de Wayland
-- ==============================================================================

-- Binarios de usuario (eww vive en ~/.local/bin). LightDM no carga ~/.profile
-- en sesiones Wayland, así que el PATH heredado no lo incluye.
local localBin = os.getenv("HOME") .. "/.local/bin"
local path = os.getenv("PATH") or ""
if not (":" .. path .. ":"):find(":" .. localBin .. ":", 1, true) then
    hl.env("PATH", localBin .. ":" .. path)
end

-- Soporte Wayland para Firefox y Qt
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")

-- Temática
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Catppuccin-Macchiato-Standard-Blue-Dark")

-- Hinting para electron/wayland nativo
hl.env("OZONE_PLATFORM", "wayland")
