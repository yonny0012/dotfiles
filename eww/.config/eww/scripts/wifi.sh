#!/bin/bash

# Función para listar redes en formato JSON
get_networks() {
    nmcli -t -f "SSID,BARS,SECURITY,ACTIVE" device wifi list | \
    awk -F: '{
        # Skip empty SSIDs
        if ($1 == "") next;
        
        # Escapar comillas dobles y barras invertidas en SSID para evitar JSON inválido
        gsub(/\\/, "\\\\", $1);
        gsub(/"/, "\\\", $1);
        
        # Convert bars to percentage or keep as is
        bars = $2;
        
        # Determine security status
        security = ($3 != "" && $3 != "--") ? $3 : "";
        
        # Determine if active
        active = ($4 == "*" || $4 == "yes") ? "yes" : "no";
        
        printf "{\"ssid\": \"%s\", \"bars\": \"%s\", \"security\": \"%s\", \"active\": \"%s\"}\n", $1, bars, security, active
    }' | \
    jq -s '.'
}

# Si pasas el argumento "connect", manejamos la conexión
if [ "$1" == "--connect" ]; then
    nmcli device wifi connect "$2"
else
    get_networks
fi