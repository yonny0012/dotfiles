-- ==============================================================================
-- Execs (Autostart)
-- En hyprlang era exec-once = ...; en Lua se usa el evento hyprland.start
-- ==============================================================================

hl.on("hyprland.start", function()
    -- Demonios esenciales
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("waybar")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("mako")
    hl.exec_cmd("cliphist daemon") -- Historial del portapapeles
    hl.exec_cmd("udiskie") -- monta discos y unidades removibles
    hl.exec_cmd("hypridle")

    -- Portapapeles
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Wallpaper daemon
    hl.exec_cmd("swaybg -m fill -i ~/Pictures/background.jpg")

    -- Cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")

    -- Tema GTK
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Macchiato-Mauve"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface font-name "JetBrains Mono 10"')
end)
