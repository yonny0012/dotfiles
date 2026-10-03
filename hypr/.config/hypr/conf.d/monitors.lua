-- ==============================================================================
-- Monitores e Inputs
-- ==============================================================================

-- Detección automática (reemplazar si usas multi-monitor con posiciones fijas)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Input general
hl.config({
    input = {
        kb_layout  = "us,es",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:win_space_toggle",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 a 1.0

        touchpad = {
            natural_scroll = true,
            tap_to_click   = false,
        },
    },
})

-- Gestures
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
