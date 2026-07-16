#!/usr/bin/env bash
set -euo pipefail

# metric_collector.sh
#
# Contract (snapshot):
# {
#   "ts": <unix epoch seconds>,
#   "cpu": <0-100>,
#   "ram": <0-100>,
#   "disk": <0-100>,
#   "gpu": <0-100>,
#   "net": <0-100>,
#   "cpu_freq": "<GHz string>",
#   "ram_used_gb": "<used GB>",
#   "ram_total_gb": "<total GB>",
#   "disk_used_gb": "<used GB>",
#   "disk_total_gb": "<total GB>",
#   "gpu_temp": "<temp string>",
#   "net_down_speed": "<human readable>",
#   "net_up_speed": "<human readable>",
#   "stale": {"cpu": <bool>, "ram": <bool>, "disk": <bool>, "net": <bool>}
# }
#
# Scale definitions:
# - cpu: delta from /proc/stat normalized to 0-100
# - ram: (MemTotal - MemAvailable) / MemTotal * 100
# - disk: df use% for /
# - net: combined RX+TX throughput normalized against NET_CAP_BYTES_PER_SEC
#
# Freshness tolerance:
# - stale=true when last successful update is older than STALE_TOLERANCE_SEC.

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eww"
STATE_FILE="${STATE_DIR}/metric_collector.state"
NET_CAP_BYTES_PER_SEC="${NET_CAP_BYTES_PER_SEC:-12500000}"
STALE_TOLERANCE_SEC="${STALE_TOLERANCE_SEC:-4}"

mkdir -p "${STATE_DIR}"

clamp_0_100() {
  local value="$1"
  if (( value < 0 )); then
    printf '0\n'
    return
  fi
  if (( value > 100 )); then
    printf '100\n'
    return
  fi
  printf '%s\n' "$value"
}

read_state() {
  if [[ -f "${STATE_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${STATE_FILE}"
  fi
}

write_state() {
  cat > "${STATE_FILE}" <<EOF
LAST_TS=${LAST_TS:-0}
LAST_SUCCESS_TS=${LAST_SUCCESS_TS:-0}
PREV_CPU_TOTAL=${PREV_CPU_TOTAL:-0}
PREV_CPU_IDLE=${PREV_CPU_IDLE:-0}
PREV_NET_RX=${PREV_NET_RX:-0}
PREV_NET_TX=${PREV_NET_TX:-0}
CPU_LAST=${CPU_LAST:-0}
RAM_LAST=${RAM_LAST:-0}
DISK_LAST=${DISK_LAST:-0}
NET_LAST=${NET_LAST:-0}
GPU_LAST=${GPU_LAST:-0}
SWAP_LAST=${SWAP_LAST:-0}
CPU_FREQ_LAST='${CPU_FREQ_LAST:-0}'
RAM_USED_GB_LAST='${RAM_USED_GB_LAST:-0}'
RAM_TOTAL_GB_LAST='${RAM_TOTAL_GB_LAST:-0}'
DISK_USED_GB_LAST='${DISK_USED_GB_LAST:-0}'
DISK_TOTAL_GB_LAST='${DISK_TOTAL_GB_LAST:-0}'
GPU_TEMP_LAST='${GPU_TEMP_LAST:---}'
NET_DOWN_SPEED_LAST='${NET_DOWN_SPEED_LAST:-0 B/s}'
NET_UP_SPEED_LAST='${NET_UP_SPEED_LAST:-0 B/s}'
EOF
}

cpu_percent() {
  local user nice system idle iowait irq softirq steal guest guest_nice
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local idle_all=$((idle + iowait))
  local non_idle=$((user + nice + system + irq + softirq + steal))
  local total=$((idle_all + non_idle))

  local result=0
  if [[ -n "${PREV_CPU_TOTAL:-}" && -n "${PREV_CPU_IDLE:-}" ]]; then
    local totald=$((total - PREV_CPU_TOTAL))
    local idled=$((idle_all - PREV_CPU_IDLE))
    if (( totald > 0 )); then
      result=$(( (100 * (totald - idled)) / totald ))
    fi
  fi

  # Set globals directly — must NOT be called via $() subshell
  PREV_CPU_TOTAL=$total
  PREV_CPU_IDLE=$idle_all
  CPU_LAST=$(clamp_0_100 "$result")
}

cpu_freq() {
  # Current average CPU frequency in GHz
  local freq_mhz
  freq_mhz=$(awk '/^cpu MHz/ {sum += $4; n++} END {if (n > 0) printf "%.1f", sum / n / 1000; else print "0"}' /proc/cpuinfo 2>/dev/null)
  if [[ -z "$freq_mhz" || "$freq_mhz" == "0" ]]; then
    # Fallback to lscpu
    freq_mhz=$(lscpu 2>/dev/null | awk '/^CPU.*MHz/ {printf "%.1f", $NF / 1000; exit}')
  fi
  printf '%s\n' "${freq_mhz:-0}"
}

ram_percent() {
  local total available
  total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  if [[ -z "${total}" || -z "${available}" || "${total}" -le 0 ]]; then
    RAM_LAST="${RAM_LAST:-0}"
    return
  fi

  local used=$((total - available))
  local pct=$(( (used * 100) / total ))
  RAM_LAST=$(clamp_0_100 "$pct")
}

ram_detail() {
  local total available used
  total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  used=$((total - available))
  # kB to GB with one decimal
  RAM_USED_GB_LAST=$(awk "BEGIN {printf \"%.1f\", ${used} / 1048576}")
  RAM_TOTAL_GB_LAST=$(awk "BEGIN {printf \"%.1f\", ${total} / 1048576}")
}

disk_percent() {
  local used_pct
  used_pct=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
  if [[ -z "${used_pct}" ]]; then
    DISK_LAST="${DISK_LAST:-0}"
    return
  fi
  DISK_LAST=$(clamp_0_100 "$used_pct")
}

disk_detail() {
  local used_kb total_kb
  read -r used_kb total_kb <<< "$(df -P / | awk 'NR==2 {print $3, $2}')"
  DISK_USED_GB_LAST=$(awk "BEGIN {printf \"%.0f\", ${used_kb:-0} / 1048576}")
  DISK_TOTAL_GB_LAST=$(awk "BEGIN {printf \"%.0f\", ${total_kb:-0} / 1048576}")
}

swap_percent() {
  local total free
  total=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo 2>/dev/null)
  free=$(awk '/^SwapFree:/ {print $2}' /proc/meminfo 2>/dev/null)
  if [[ -z "${total}" || "${total}" -le 0 ]]; then
    SWAP_LAST=0
    return
  fi
  local used=$((total - free))
  local pct=$(( (used * 100) / total ))
  SWAP_LAST=$(clamp_0_100 "$pct")
}

gpu_percent() {
  local val
  if command -v nvidia-smi &>/dev/null; then
    val=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
  elif [[ -f /sys/class/drm/card0/device/gpu_busy_percent ]]; then
    val=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null)
  else
    val=0
  fi
  GPU_LAST="${val:-0}"
}

gpu_temp() {
  if command -v nvidia-smi &>/dev/null; then
    local temp
    temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
    printf '%s°C\n' "${temp:-N/A}"
  elif [[ -d /sys/class/hwmon ]]; then
    # Try to find GPU temperature from hwmon
    local temp_file
    for hwmon_dir in /sys/class/hwmon/hwmon*/; do
      if grep -qi 'amdgpu\|radeon\|gpu' "${hwmon_dir}name" 2>/dev/null; then
        temp_file="${hwmon_dir}temp1_input"
        if [[ -f "$temp_file" ]]; then
          local raw
          raw=$(cat "$temp_file" 2>/dev/null)
          printf '%s°C\n' "$((raw / 1000))"
          return
        fi
      fi
    done
    echo "N/A"
  else
    echo "N/A"
  fi
}

format_speed() {
  local bytes_per_sec="$1"
  if (( bytes_per_sec >= 1048576 )); then
    awk "BEGIN {printf \"%.1f MB/s\", ${bytes_per_sec} / 1048576}"
  elif (( bytes_per_sec >= 1024 )); then
    awk "BEGIN {printf \"%.0f KB/s\", ${bytes_per_sec} / 1024}"
  else
    printf '%s B/s\n' "$bytes_per_sec"
  fi
}

net_percent() {
  local rx tx now_ts
  rx=$(awk -F '[: ]+' '/:/ && $1 !~ /lo/ {sum += $3} END {print sum+0}' /proc/net/dev)
  tx=$(awk -F '[: ]+' '/:/ && $1 !~ /lo/ {sum += $11} END {print sum+0}' /proc/net/dev)
  now_ts=$(date +%s)

  local pct=0
  local down_bps=0
  local up_bps=0

  if [[ -n "${PREV_NET_RX:-}" && -n "${PREV_NET_TX:-}" && -n "${LAST_TS:-}" ]]; then
    local delta_rx=$((rx - PREV_NET_RX))
    local delta_tx=$((tx - PREV_NET_TX))
    local delta_t=$((now_ts - LAST_TS))
    [[ $delta_rx -lt 0 ]] && delta_rx=0
    [[ $delta_tx -lt 0 ]] && delta_tx=0

    if (( delta_t > 0 )); then
      down_bps=$((delta_rx / delta_t))
      up_bps=$((delta_tx / delta_t))
      local total_bps=$((down_bps + up_bps))
      if (( NET_CAP_BYTES_PER_SEC > 0 )); then
        pct=$(( (total_bps * 100) / NET_CAP_BYTES_PER_SEC ))
      fi
    fi
  fi

  # Set globals directly — must NOT be called via $() subshell
  PREV_NET_RX=$rx
  PREV_NET_TX=$tx
  NET_DOWN_SPEED_LAST=$(format_speed "$down_bps")
  NET_UP_SPEED_LAST=$(format_speed "$up_bps")
  NET_LAST=$(clamp_0_100 "$pct")
}

emit_snapshot() {
  read_state

  LAST_TS="${LAST_TS:-0}"
  LAST_SUCCESS_TS="${LAST_SUCCESS_TS:-0}"
  PREV_CPU_TOTAL="${PREV_CPU_TOTAL:-0}"
  PREV_CPU_IDLE="${PREV_CPU_IDLE:-0}"
  PREV_NET_RX="${PREV_NET_RX:-0}"
  PREV_NET_TX="${PREV_NET_TX:-0}"
  CPU_LAST="${CPU_LAST:-0}"
  RAM_LAST="${RAM_LAST:-0}"
  DISK_LAST="${DISK_LAST:-0}"
  NET_LAST="${NET_LAST:-0}"
  GPU_LAST="${GPU_LAST:-0}"
  SWAP_LAST="${SWAP_LAST:-0}"

  local ok=true

  # Call directly — these functions set globals (CPU_LAST, NET_LAST, etc.)
  # Do NOT use $() capture or side-effects are lost in subshell.
  if ! cpu_percent; then ok=false; fi
  if ! ram_percent; then ok=false; fi
  if ! disk_percent; then ok=false; fi
  if ! swap_percent; then ok=false; fi
  if ! net_percent; then ok=false; fi
  if ! gpu_percent; then ok=false; fi

  # NOW update the timestamp for the next cycle
  LAST_TS=$(date +%s)

  # Detail metrics
  CPU_FREQ_LAST=$(cpu_freq)
  ram_detail
  disk_detail
  GPU_TEMP_LAST=$(gpu_temp)

  if [[ "${ok}" == "true" ]]; then
    LAST_SUCCESS_TS=$LAST_TS
  fi

  local last_success="${LAST_SUCCESS_TS:-0}"
  local age=$((LAST_TS - last_success))
  local stale=false
  if (( last_success == 0 || age > STALE_TOLERANCE_SEC )); then
    stale=true
  fi
  STALE_BOOL="$stale"

  write_state

  printf '{"ts":%s,"cpu":%s,"ram":%s,"disk":%s,"swap":%s,"gpu":%s,"net":%s,"cpu_freq":"%s","ram_used_gb":"%s","ram_total_gb":"%s","disk_used_gb":"%s","disk_total_gb":"%s","gpu_temp":"%s","net_down_speed":"%s","net_up_speed":"%s","stale":{"cpu":%s,"ram":%s,"disk":%s,"net":%s}}\n' \
    "$LAST_TS" \
    "${CPU_LAST:-0}" \
    "${RAM_LAST:-0}" \
    "${DISK_LAST:-0}" \
    "${SWAP_LAST:-0}" \
    "${GPU_LAST:-0}" \
    "${NET_LAST:-0}" \
    "${CPU_FREQ_LAST:-0}" \
    "${RAM_USED_GB_LAST:-0}" \
    "${RAM_TOTAL_GB_LAST:-0}" \
    "${DISK_USED_GB_LAST:-0}" \
    "${DISK_TOTAL_GB_LAST:-0}" \
    "${GPU_TEMP_LAST:---}" \
    "${NET_DOWN_SPEED_LAST:-0 B/s}" \
    "${NET_UP_SPEED_LAST:-0 B/s}" \
    "$STALE_BOOL" "$STALE_BOOL" "$STALE_BOOL" "$STALE_BOOL"
}

emit_value() {
  local key="$1"
  emit_snapshot >/dev/null
  case "$key" in
    cpu)            printf '%s\n' "${CPU_LAST:-0}" ;;
    ram)            printf '%s\n' "${RAM_LAST:-0}" ;;
    disk)           printf '%s\n' "${DISK_LAST:-0}" ;;
    swap)           printf '%s\n' "${SWAP_LAST:-0}" ;;
    net)            printf '%s\n' "${NET_LAST:-0}" ;;
    gpu)            printf '%s\n' "${GPU_LAST:-0}" ;;
    cpu_freq)       printf '%s\n' "${CPU_FREQ_LAST:-0}" ;;
    ram_used_gb)    printf '%s\n' "${RAM_USED_GB_LAST:-0}" ;;
    ram_total_gb)   printf '%s\n' "${RAM_TOTAL_GB_LAST:-0}" ;;
    disk_used_gb)   printf '%s\n' "${DISK_USED_GB_LAST:-0}" ;;
    disk_total_gb)  printf '%s\n' "${DISK_TOTAL_GB_LAST:-0}" ;;
    gpu_temp)       printf '%s\n' "${GPU_TEMP_LAST:---}" ;;
    net_down_speed) printf '%s\n' "${NET_DOWN_SPEED_LAST:-0 B/s}" ;;
    net_up_speed)   printf '%s\n' "${NET_UP_SPEED_LAST:-0 B/s}" ;;
    ts)             printf '%s\n' "${LAST_TS:-0}" ;;
    stale.*)        printf '%s\n' "$STALE_BOOL" ;;
    status.*)
      if [[ "$STALE_BOOL" == "true" ]]; then
        printf 'STALE\n'
      else
        printf 'FRESH\n'
      fi
      ;;
    *)
      printf 'invalid value key: %s\n' "$key" >&2
      return 2
      ;;
  esac
}

emit_cached_value() {
  local key="$1"
  read_state

  LAST_TS="${LAST_TS:-0}"
  LAST_SUCCESS_TS="${LAST_SUCCESS_TS:-0}"

  local now_ts
  now_ts=$(date +%s)
  local last_success="${LAST_SUCCESS_TS:-0}"
  local age=$((now_ts - last_success))
  local stale=false
  if (( last_success == 0 || age > STALE_TOLERANCE_SEC )); then
    stale=true
  fi

  case "$key" in
    cpu)            printf '%s\n' "${CPU_LAST:-0}" ;;
    ram)            printf '%s\n' "${RAM_LAST:-0}" ;;
    disk)           printf '%s\n' "${DISK_LAST:-0}" ;;
    swap)           printf '%s\n' "${SWAP_LAST:-0}" ;;
    net)            printf '%s\n' "${NET_LAST:-0}" ;;
    gpu)            printf '%s\n' "${GPU_LAST:-0}" ;;
    cpu_freq)       printf '%s\n' "${CPU_FREQ_LAST:-0}" ;;
    ram_used_gb)    printf '%s\n' "${RAM_USED_GB_LAST:-0}" ;;
    ram_total_gb)   printf '%s\n' "${RAM_TOTAL_GB_LAST:-0}" ;;
    disk_used_gb)   printf '%s\n' "${DISK_USED_GB_LAST:-0}" ;;
    disk_total_gb)  printf '%s\n' "${DISK_TOTAL_GB_LAST:-0}" ;;
    gpu_temp)       printf '%s\n' "${GPU_TEMP_LAST:---}" ;;
    net_down_speed) printf '%s\n' "${NET_DOWN_SPEED_LAST:-0 B/s}" ;;
    net_up_speed)   printf '%s\n' "${NET_UP_SPEED_LAST:-0 B/s}" ;;
    ts)             printf '%s\n' "${LAST_TS:-0}" ;;
    stale.*)        printf '%s\n' "$stale" ;;
    status.*)
      if [[ "$stale" == "true" ]]; then
        printf 'STALE\n'
      else
        printf 'FRESH\n'
      fi
      ;;
    *)
      printf 'invalid read key: %s\n' "$key" >&2
      return 2
      ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  metric_collector.sh snapshot
  metric_collector.sh stream
  metric_collector.sh value <key>
  metric_collector.sh read <key>

Keys: cpu, ram, disk, net, gpu, cpu_freq, ram_used_gb, ram_total_gb,
      disk_used_gb, disk_total_gb, gpu_temp, net_down_speed, net_up_speed,
      ts, stale.*, status.*
EOF
}

main() {
  local command="${1:-snapshot}"
  case "$command" in
    snapshot)
      emit_snapshot
      ;;
    stream)
      # Continuous JSON stream for eww deflisten
      while true; do
        emit_snapshot
        sleep 2
      done
      ;;
    value)
      if [[ -z "${2:-}" ]]; then
        usage
        exit 2
      fi
      emit_value "$2"
      ;;
    read)
      if [[ -z "${2:-}" ]]; then
        usage
        exit 2
      fi
      emit_cached_value "$2"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
