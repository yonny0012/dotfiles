# RAM + CPU Monitoring
## persona
eres un desarollador software, ingeniero y arquitecto de software, experimentado
en entornos linux unix y adminisrtracion de sistemas. con mas de 10 anhos de experiencia 
en el mundo Tech/IT, power user de linux, personalizaciones y setups minuciosamente escogido
con herramientas seleccionadas segun la necesidad del sistema, enfocado en productividad 
y rendimiento.

---
## tarea
actualiza la configuracion referenciada para tener en la barra de estado del sistema *waybar*
unos graficos en los que visualice el uso de ram y cpu en timepo real.

### referencias

*~/dotfiles/waybar/.config/waybar/config.jsonc*

```json
{
    // =========================================================================
    // Waybar Configuration (Glassmorphism & Catppuccin Macchiato)
    // Arch: GNU Stow
    // =========================================================================
    "layer": "top",
    "position": "top",
    // Spacing for floating effect (UI/UX Best Practice: "top-4 left-4 right-4")
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "margin-bottom": 0,
    "height": 40,
    "spacing": 8,
    // Modules order
    "modules-left": [
        "custom/launcher",
        "hyprland/workspaces",
        "hyprland/window"
    ],
    "modules-center": [
        "clock"
    ],
    "modules-right": [
        "tray",
        "pulseaudio",
        "network",
        "battery",
        "custom/power"
    ],
    // --- [ Left Modules ] ----------------------------------------------------
    "custom/launcher": {
        "format": "",
        "on-click": "wofi --show drun",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "active-only": false,
        "on-click": "activate",
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "󰈹",
            "3": "󰨞",
            "4": "󰭹",
            "5": "",
            "6": "",
            "urgent": "",
            "active": "",
            "default": ""
        },
        // Smooth hover transitions via CSS, logic only here
        "persistent-workspaces": {
            "*": 6
        }
    },
    "hyprland/window": {
        "format": "{title}",
        "max-length": 40,
        "rewrite": {
            "(.*) - Mozilla Firefox": "󰈹 $1",
            "(.*) - fish": " [$1]",
            "(.*) - Brave": " $1",
            "(.*) - Tor Browser": " $1",
            "(.*) - Google Chrome": " $1",
            "(.*) - Visual Studio Code": " $1"
        }
    },
    // --- [ Center Modules ] --------------------------------------------------
    "clock": {
        "format": "  {:%I:%M %p}",
        "format-alt": "  {:%A, %B %d, %Y}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
            "mode": "year",
            "mode-mon-col": 3,
            "weeks-pos": "right",
            "on-scroll": 1,
            "format": {
                "months": "<span color='#cad3f5'><b>{}</b></span>",
                "days": "<span color='#b8c0e0'>{}</span>",
                "weeks": "<span color='#8aadf4'>W{}</span>",
                "weekdays": "<span color='#eed49f'><b>{}</b></span>",
                "today": "<span color='#ed8796'><b><u>{}</u></b></span>"
            }
        }
    },
    // --- [ Right Modules ] ---------------------------------------------------
    "pulseaudio": {
        "format": "{icon}  {volume}%",
        "format-muted": "󰝟  Muted",
        "format-icons": {
            "headphone": "󰋋",
            "hands-free": "󰋋",
            "headset": "󰋋",
            "phone": "",
            "portable": "",
            "car": "",
            "default": [
                "󰕿",
                "󰖀",
                "󰕾"
            ]
        },
        "on-click": "pavucontrol"
    },
    "network": {
        "format-wifi": "󰖩  {essid} ({signalStrength}%)",
        "format-ethernet": "󰈀  {ipaddr}",
        "tooltip-format": "{ifname} via {gwaddr}",
        "format-linked": "󰈁  {ifname} (No IP)",
        "format-disconnected": "󰖪  Disconnected",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "on-click-right": "nm-connection-editor",
        "on-click": "eww open --toggle wifi_menu"
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon}  {capacity}%",
        "format-charging": "󰂄 {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": [
            "󰁺",
            "󰁻",
            "󰁼",
            "󰁽",
            "󰁾",
            "󰁿",
            "󰂀",
            "󰂁",
            "󰂂",
            "󰁹"
        ]
    },
    "tray": {
        "icon-size": 16,
        "spacing": 10
    },
    "custom/power": {
        "format": "⏻",
        "on-click": "eww open --toggle dashboard",
        "tooltip": false
    }
}
```

*~/dotfiles/waybar/.config/waybar/style.css*

```css
/* =============================================================================
 * Waybar Stylesheet (CSS)
 * Pattern: Glassmorphism Modern Dark
 * Colors: Catppuccin Macchiato
 * Typography: Fira Code / Fira Sans (Fallback to System UI)
 * ========================================================================== */

* {
    /* Typographic hierarchy dictated by ui-ux-pro-max */
    font-family: "JetBrainsMono Nerd Font", "Fira Code", sans-serif;
    font-size: 14px;
    font-weight: 500;
    /* Remove padding globally, apply per-element for predictability */
    border: none;
    border-radius: 0;
}

window#waybar {
    /* True Glassmorphism: Dark base with heavy transparency 
       (Hyprland handles the actual backdrop-filter blur via layerrule) */
    background: rgba(36, 39, 58, 0.4);
    color: #cad3f5;
    /* Text */
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    /* subtle shadow */
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

/* --- [ Modules Container Logic ] -------------------------------------------- */
/* Grouping for clean spacing */
.modules-left,
.modules-center,
.modules-right {
    margin: 4px;
    background: transparent;
}

/* Ensure all clickable modules have pointer (UX rules) */
#workspaces button,
#clock,
#pulseaudio,
#network,
#battery,
#tray,
#custom-power,
#custom-launcher {
    padding: 0 12px;
    margin: 0 4px;
    background: rgba(30, 32, 48, 0.6);
    /* Mantle (darker) */
    color: #cad3f5;
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Hover states (Smooth transitions required by UI/UX guide) */
#workspaces button:hover,
#clock:hover,
#pulseaudio:hover,
#network:hover,
#battery:hover,
#tray:hover,
#custom-power:hover,
#custom-launcher:hover {
    background: rgba(91, 96, 120, 0.8);
    /* Surface2 */
    color: #f4dbd6;
    /* Rosewater */
    box-shadow: 0 0 10px rgba(183, 189, 248, 0.2);
}

/* --- [ Specific Module Styling ] -------------------------------------------- */
#custom-launcher {
    color: #8aadf4;
    /* Blue accent */
    font-size: 16px;
    padding-right: 14px;
    margin-left: 2px;
}

/* Workspaces */
#workspaces {
    background: transparent;
}

#workspaces button {
    padding: 0 8px;
    margin: 0 2px;
    font-size: 16px;
}

#workspaces button.active {
    background: rgba(198, 160, 246, 0.2);
    /* Mauve transparent */
    color: #c6a0f6;
    /* Mauve solid */
    border: 1px solid rgba(198, 160, 246, 0.4);
}

#workspaces button.urgent {
    background: rgba(237, 135, 150, 0.2);
    /* Red transparent */
    color: #ed8796;
    /* Red solid */
    border: 1px solid rgba(237, 135, 150, 0.4);
}

/* Window Title */
#window {
    margin-left: 12px;
    font-weight: 400;
    color: #b8c0e0;
    /* Subtext1 */
}

/* Center Clock */
#clock {
    font-weight: 600;
    color: #8aadf4;
    /* Blue */
    background: rgba(138, 173, 244, 0.1);
}

/* Right Indicators */
#pulseaudio {
    color: #eed49f;
    /* Yellow */
}

#pulseaudio.muted {
    color: #ed8796;
    /* Red */
}

#network {
    color: #a6da95;
    /* Green */
}

#network.disconnected {
    color: #ed8796;
    /* Red */
}

#battery {
    color: #8bd5ca;
    /* Teal */
}

#battery.charging {
    color: #a6da95;
    /* Green */
}

#battery.warning {
    color: #f5a97f;
    /* Peach */
    background: rgba(245, 169, 127, 0.1);
}

#battery.critical {
    color: #ed8796;
    /* Red */
    background: rgba(237, 135, 150, 0.2);
    animation: blink 2s linear infinite;
}

#custom-power {
    color: #ed8796;
    /* Red accent for closing/Eww */
    margin-right: 2px;
    font-size: 16px;
    padding: 0 14px;
}

#mpd {
    background-color: rgba(36, 39, 58, 0.4);
    color: #b4befe;
    padding: 0 10px;
    margin: 0 5px;
    border-radius: 8px;
}

/* Animations */
@keyframes blink {
    to {
        background-color: rgba(237, 135, 150, 0.6);
        color: #24273a;
    }
}
```
---
## extra
[] sugerencias de mejoras y optimizaciones para la configuracion de waybar, que puedan mejorar el rendimiento y la estetica del sistema.
[] sugerencias de herramientas y utilidades que puedan complementar la configuracion de waybar para mejorar la experiencia del usuario y la productividad.