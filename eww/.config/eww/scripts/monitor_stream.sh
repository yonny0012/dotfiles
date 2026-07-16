#!/usr/bin/env bash
# monitor_stream.sh - emite CPU/RAM/swap en JSON, línea por línea, para deflisten

CRIT_CPU=90
CRIT_MEM=85
CRIT_SWAP=50
NOTIFY_COOLDOWN=30  # segundos entre notificaciones repetidas
last_notify_cpu=0
last_notify_mem=0

get_cpu() {
    read -r _ u1 n1 s1 i1 _ < /proc/stat
    sleep 0.5
    read -r _ u2 n2 s2 i2 _ < /proc/stat
    local t1=$((u1+n1+s1+i1)) t2=$((u2+n2+s2+i2))
    local idle=$((i2-i1)) total=$((t2-t1))
    echo $(( total>0 ? (100*(total-idle))/total : 0 ))
}

get_mem() {
    awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", (t-a)*100/t}' /proc/meminfo
}

get_swap() {
    awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END{ if(t==0){print 0} else {printf "%d", (t-f)*100/t} }' /proc/meminfo
}

maybe_notify() {
    local label="$1" value="$2" crit="$3" last_var="$4"
    local now=$(date +%s)
    local last
    eval "last=\$$last_var"
    if (( value >= crit && now - last > NOTIFY_COOLDOWN )); then
        notify-send -u critical "⚠ $label alto" "$label al ${value}% — revisa antes de que se congele" -i dialog-warning
        eval "$last_var=$now"
    fi
}

while true; do
    cpu=$(get_cpu)
    mem=$(get_mem)
    swap=$(get_swap)

    maybe_notify "CPU" "$cpu" "$CRIT_CPU" last_notify_cpu
    maybe_notify "RAM" "$mem" "$CRIT_MEM" last_notify_mem

    printf '{"cpu": %d, "mem": %d, "swap": %d}\n' "$cpu" "$mem" "$swap"
done