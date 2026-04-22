# Automatizacion de comprobaciones

## descripcion

automatiza el flujo de codificar - verificar

## metodo

justo despues de aplicar cambios, verifica que el archivo de log no tenga errores recientesdespues de correr el reinicio de **eww**

## pasos

1. aplica el cambio
2. ejecuta `eww kill & eww daemond &`
3. lee el archivo [logs](/home/devshw/.cache/eww/eww_b26cc01e878aafd4.log)
4. corrigee itera hasta que los comandos pasen limpios y en log no se registren fallos

## herramientas

- usa **context7 mcp** para leer documentacon actualizada
- hay ejemplo de codigo en [examples](/home/devshw/Workspace/examples/)
