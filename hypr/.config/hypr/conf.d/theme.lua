-- ==============================================================================
-- Theme, Animations & Glassmorphism
-- Paleta base: Catppuccin Macchiato
-- ==============================================================================

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = {
            colors = { "rgb(c6a0f6)", "rgb(8aadf4)" },
            angle = 45,
        },
        ["col.inactive_border"] = "rgb(6e738d)",
        layout = "dwindle",
        resize_on_border = true,
    },
})

hl.config({
    decoration = {
        rounding = 12,

        blur = {
            enabled = true,
            size = 8,
            passes = 3,
        },

        shadow = {
            enabled = true,
            range = 15,
            render_power = 3,
            color = "rgba(11111b99)",
        },
    },
})

-- ── Curvas (beziers) ─────────────────────────────────────────────────────────
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },      { 1, 1 }    } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },   { 0.1, 1 }  } })

-- ── Animaciones ──────────────────────────────────────────────────────────────
hl.animation({ leaf = "global",      enabled = true, speed = 10,   bezier = "default" })

hl.animation({ leaf = "border",      enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",     enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3.03, bezier = "linear" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
