## Exploration: Corrigiendo por qué no funcionan Super+T y Super+W

### Current State
El usuario reporta que los atajos de teclado `Super+T` y `Super+W` no funcionan. La configuración de Hyprland (`hypr/.config/hypr/conf.d/keybinds.conf`) los define de la siguiente manera:
- `bind = $mainMod, t, exec, $terminal`
- `bind = $mainMod, w, exec, eww open --toggle dashboard`

En la cabecera tenemos las variables:
```hyprland
$terminal = kitty
$browser = brave-browser &
```

### Affected Areas
- `hypr/.config/hypr/conf.d/keybinds.conf` — Archivo principal donde están los atajos problemáticos y las variables no utilizadas.

### Análisis de las fallas
1. **Falla de Super+W:**
   - **Causa 1 (Lógica del atajo):** El usuario definió la variable `$browser` para usar `brave-browser`, pero **NUNCA la asignó a ningún atajo**. En su lugar, mapeó `Super+W` al comando `eww open --toggle dashboard`.
   - Si el usuario esperaba que abriera el navegador (común por la inicial "W" de Web), percibe que el atajo "falla" porque no abre nada o trata de abrir el dashboard en el fondo.
   - **Causa 2 (Sintaxis):** La sintaxis `$browser = brave-browser &` es incorrecta y es un vicio de bash. En Hyprland el dispatcher `exec` ya lanza la aplicación en segundo plano por diseño.

2. **Falla de Super+T:**
   - **Causa:** Está mapeado a `exec, $terminal` (es decir, `kitty`). El atajo en sí mismo tiene la sintaxis correcta. Si el usuario arregló el typo `ll` previamente (que estaba en `XF86MonBrightnessDown` como vimos en el diff de git), no afecta a `$terminal`. Es posible que Kitty no esté arrancando, o bien que el propio usuario pensaba que debía invocar la terminal con otro botón clásico (ej. Super+Enter) y asumió que la "T" estaba rota.

### Approaches
1. **Corregir Mapeos y Sintaxis (Recomendado)**
   - Limpiar el `&` innecesario de `$browser`.
   - Reasignar `Super+W` a `$browser` (para el navegador web).
   - Asignar el dashboard de Eww a un atajo alternativo adecuado que no colisione.
   - Verificar si la "T" se solapa mentalmente con otro comando que el usuario acostumbra.
   - Pros: Ataca el problema de concepto, educa sobre `exec` en Wayland.
   - Cons: Ninguno.
   - Effort: Low

### Recommendation
Aplicar el Enfoque 1. Hay que educar constructivamente al usuario de que meter un `&` al final de una variable de Hyprland arrastra costumbres de bash que rompen el comando bajo Wayland (`exec` ya hace el fork). Además, declaraste la variable del browser ¡pero nunca la usaste, loco!

### Risks
- Conflictos con atajos ya asignados al mover el dashboard.

### Ready for Proposal
Yes — Dile al usuario lo que encontramos sobre la confusión de asignación de teclas y el problema con la sintaxis de fondo.