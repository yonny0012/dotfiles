# ==============================================================================
# Fish Config: 30-gaming.fish
# Entorno y helpers para juegos de Windows (Steam/Proton, Wine, Heroic).
# Nada de acá altera el rendimiento general: es caché de shaders y wrappers
# que solo actúan cuando se invocan.
# ==============================================================================

status is-interactive || exit

# --- [ Mesa: caché de shaders ] -----------------------------------------------
# Por defecto Mesa guarda 1 GiB; los juegos de Proton compilan miles de shaders
# y al llenarse el caché se tiran y recompilan (stutter recurrente). 8 GiB
# elimina ese ciclo sin costo en ejecución ni en desarrollo.
set -gx MESA_SHADER_CACHE_MAX_SIZE 8G

# --- [ Helpers ] --------------------------------------------------------------

# gamelog: lanza un juego con GameMode + OSD de MangoHud.
# Uso: gamelog <comando y argumentos>   ej: gamelog wine juego.exe
function gamelog --description "Ejecuta un juego con gamemode y MangoHud"
    if not type -q gamemoderun
        echo "gamelog: falta gamemode → bash ~/dotfiles/scripts/setup-gaming.sh" >&2
        return 1
    end
    if not type -q mangohud
        echo "gamelog: falta mangohud → bash ~/dotfiles/scripts/setup-gaming.sh" >&2
        return 1
    end
    # WINEDEBUG=-all solo aplica a procesos Wine; reduce el costo de logging.
    env WINEDEBUG=-all gamemoderun mangohud $argv
end

# opciones-fsr: imprime la cadena de opciones de lanzamiento de Steam con FSR
# interno de Proton (upscaling desde una resolución menor). Pensado para la
# UHD 620, que no llega a 768p en títulos 3D.
# Uso: opciones-fsr [0-5]   (0 = más nítido, 5 = más rendimiento; 2 por defecto)
function opciones-fsr --description "Muestra opciones de lanzamiento de Steam con FSR"
    set -l fuerza (echo $argv[1] | string match -r '^[0-5]$')
    or set fuerza 2
    echo "WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=$fuerza gamemoderun mangohud %command%"
    echo "" >&2
    echo "Pegar en Steam → Propiedades → Opciones de lanzamiento." >&2
    echo "Nota: FSR no funciona junto a PROTON_ENABLE_WAYLAND=1 (usar XWayland)." >&2
end
