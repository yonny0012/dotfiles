-- ==============================================================================
-- MAIN HYPRLAND CONFIGURATION (LUA - MODULAR)
-- ==============================================================================
-- Punto de entrada. La lógica vive en conf.d/*.lua como módulos separados.
-- Cada require() es un scope aislado: un error en un módulo no mata los demás.

-- 1. Variables de entorno y Monitores
require("./conf.d/env")
require("./conf.d/monitors")

-- 2. Servicios y Ejecuciones Automáticas (Waybar, Eww, Fondos)
--    Nota: hyprland.start solo dispara en el arranque de la sesión,
--    no en cada reload (los demonios no se duplican).
require("./conf.d/execs")

-- 3. Estilos (UI/UX, Glassmorphism, Bordes, Animaciones)
require("./conf.d/theme")

-- 4. Reglas de Comportamiento de Ventanas y Capas
require("./conf.d/rules")

-- 5. Atajos de Teclado (Keybinds) y Mouse
require("./conf.d/keybinds")

-- 6. Configuraciones de logs y misc
require("./conf.d/settings")
