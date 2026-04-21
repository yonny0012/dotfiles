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
#   "net": <0-100>,
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
PREV_NET_TOTAL=${PREV_NET_TOTAL:-0}
CPU_LAST=${CPU_LAST:-0}
RAM_LAST=${RAM_LAST:-0}
DISK_LAST=${DISK_LAST:-0}
NET_LAST=${NET_LAST:-0}
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

  PREV_CPU_TOTAL=$total
  PREV_CPU_IDLE=$idle_all
  clamp_0_100 "$result"
}

ram_percent() {
  local total available
  total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  if [[ -z "${total}" || -z "${available}" || "${total}" -le 0 ]]; then
    printf '%s\n' "${RAM_LAST:-0}"
    return
  fi

  local used=$((total - available))
  local pct=$(( (used * 100) / total ))
  clamp_0_100 "$pct"
}

disk_percent() {
  local used_pct
  used_pct=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
  if [[ -z "${used_pct}" ]]; then
    printf '%s\n' "${DISK_LAST:-0}"
    return
  fi
  clamp_0_100 "$used_pct"
}

net_percent() {
  local rx tx now_total now_ts
  rx=$(awk -F '[: ]+' '/:/ && $1 !~ /lo/ {sum += $3} END {print sum+0}' /proc/net/dev)
  tx=$(awk -F '[: ]+' '/:/ && $1 !~ /lo/ {sum += $11} END {print sum+0}' /proc/net/dev)
  now_total=$((rx + tx))
  now_ts=$(date +%s)

  local pct=0
  if [[ -n "${PREV_NET_TOTAL:-}" && -n "${LAST_TS:-}" ]]; then
    local delta_bytes=$((now_total - PREV_NET_TOTAL))
    local delta_t=$((now_ts - LAST_TS))
    if (( delta_bytes < 0 )); then
      delta_bytes=0
    fi
    if (( delta_t > 0 )); then
      local bytes_per_sec=$((delta_bytes / delta_t))
      if (( NET_CAP_BYTES_PER_SEC > 0 )); then
        pct=$(( (bytes_per_sec * 100) / NET_CAP_BYTES_PER_SEC ))
      fi
    fi
  fi

  PREV_NET_TOTAL=$now_total
  clamp_0_100 "$pct"
}

emit_snapshot() {
  read_state

  LAST_TS="${LAST_TS:-0}"
  LAST_SUCCESS_TS="${LAST_SUCCESS_TS:-0}"
  PREV_CPU_TOTAL="${PREV_CPU_TOTAL:-0}"
  PREV_CPU_IDLE="${PREV_CPU_IDLE:-0}"
  PREV_NET_TOTAL="${PREV_NET_TOTAL:-0}"
  CPU_LAST="${CPU_LAST:-0}"
  RAM_LAST="${RAM_LAST:-0}"
  DISK_LAST="${DISK_LAST:-0}"
  NET_LAST="${NET_LAST:-0}"

  LAST_TS=$(date +%s)
  local ok=true

  if ! CPU_LAST=$(cpu_percent); then ok=false; fi
  if ! RAM_LAST=$(ram_percent); then ok=false; fi
  if ! DISK_LAST=$(disk_percent); then ok=false; fi
  if ! NET_LAST=$(net_percent); then ok=false; fi

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

  printf '{"ts":%s,"cpu":%s,"ram":%s,"disk":%s,"net":%s,"stale":{"cpu":%s,"ram":%s,"disk":%s,"net":%s}}\n' \
    "$LAST_TS" \
    "${CPU_LAST:-0}" \
    "${RAM_LAST:-0}" \
    "${DISK_LAST:-0}" \
    "${NET_LAST:-0}" \
    "$STALE_BOOL" "$STALE_BOOL" "$STALE_BOOL" "$STALE_BOOL"
}

emit_value() {
  local key="$1"
  emit_snapshot >/dev/null
  case "$key" in
    cpu)
      printf '%s\n' "${CPU_LAST:-0}"
      ;;
    ram)
      printf '%s\n' "${RAM_LAST:-0}"
      ;;
    disk)
      printf '%s\n' "${DISK_LAST:-0}"
      ;;
    net)
      printf '%s\n' "${NET_LAST:-0}"
      ;;
    ts)
      printf '%s\n' "${LAST_TS:-0}"
      ;;
    stale.cpu|stale.ram|stale.disk|stale.net)
      printf '%s\n' "$STALE_BOOL"
      ;;
    status.cpu|status.ram|status.disk|status.net)
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

usage() {
  cat <<'EOF'
Usage:
  metric_collector.sh snapshot
  metric_collector.sh value <cpu|ram|disk|net|ts|stale.cpu|stale.ram|stale.disk|stale.net|status.cpu|status.ram|status.disk|status.net>
  metric_collector.sh read <cpu|ram|disk|net|ts|stale.cpu|stale.ram|stale.disk|stale.net|status.cpu|status.ram|status.disk|status.net>
EOF
}

emit_cached_value() {
  local key="$1"
  read_state

  LAST_TS="${LAST_TS:-0}"
  LAST_SUCCESS_TS="${LAST_SUCCESS_TS:-0}"
  CPU_LAST="${CPU_LAST:-0}"
  RAM_LAST="${RAM_LAST:-0}"
  DISK_LAST="${DISK_LAST:-0}"
  NET_LAST="${NET_LAST:-0}"

  local now_ts
  now_ts=$(date +%s)
  local last_success="${LAST_SUCCESS_TS:-0}"
  local age=$((now_ts - last_success))
  local stale=false
  if (( last_success == 0 || age > STALE_TOLERANCE_SEC )); then
    stale=true
  fi

  case "$key" in
    cpu)
      printf '%s\n' "${CPU_LAST:-0}"
      ;;
    ram)
      printf '%s\n' "${RAM_LAST:-0}"
      ;;
    disk)
      printf '%s\n' "${DISK_LAST:-0}"
      ;;
    net)
      printf '%s\n' "${NET_LAST:-0}"
      ;;
    ts)
      printf '%s\n' "${LAST_TS:-0}"
      ;;
    stale.cpu|stale.ram|stale.disk|stale.net)
      printf '%s\n' "$stale"
      ;;
    status.cpu|status.ram|status.disk|status.net)
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

main() {
  local command="${1:-snapshot}"
  case "$command" in
    snapshot)
      emit_snapshot
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
