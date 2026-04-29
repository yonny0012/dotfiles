#!/usr/bin/env bash
# ============================================
# Music info for Eww — MPD via mpc
# Returns semantic strings, NOT icon chars
# ============================================

COVER="/tmp/.music_cover.jpg"
MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"

get_status() {
  local status
  status="$(mpc status 2>/dev/null)"
  if [[ $status == *"[playing]"* ]]; then
    echo "playing"
  elif [[ $status == *"[paused]"* ]]; then
    echo "paused"
  else
    echo "stopped"
  fi
}

get_song() {
  local song
  song=$(mpc -f %title% current 2>/dev/null)
  echo "${song:-Offline}"
}

get_artist() {
  local artist
  artist=$(mpc -f %artist% current 2>/dev/null)
  echo "${artist:-Offline}"
}

get_time() {
  local time
  time=$(mpc status 2>/dev/null | grep '%)'  | awk '{print $4}' | tr -d '(%)')
  echo "${time:-0}"
}

get_ctime() {
  local ctime
  ctime=$(mpc status 2>/dev/null | grep '#' | awk '{print $3}' | sed 's|/.*||g')
  echo "${ctime:-0:00}"
}

get_ttime() {
  local ttime
  ttime=$(mpc -f %time% current 2>/dev/null)
  echo "${ttime:-0:00}"
}

get_cover() {
  local current_file
  current_file=$(mpc current -f %file% 2>/dev/null)

  if [[ -z "$current_file" ]]; then
    echo ""
    return
  fi

  local exit_code
  ffmpeg -i "${MUSIC_DIR}/${current_file}" "${COVER}" -y &>/dev/null
  exit_code=$?

  if [[ "$exit_code" -eq 0 ]]; then
    echo "$COVER"
  else
    echo ""
  fi
}

case "$1" in
  --song)    get_song ;;
  --artist)  get_artist ;;
  --status)  get_status ;;
  --time)    get_time ;;
  --ctime)   get_ctime ;;
  --ttime)   get_ttime ;;
  --cover)   get_cover ;;
  --toggle)  mpc -q toggle ;;
  --next)    mpc -q next; get_cover >/dev/null ;;
  --prev)    mpc -q prev; get_cover >/dev/null ;;
  *)
    echo "Usage: $0 {--song|--artist|--status|--time|--ctime|--ttime|--cover|--toggle|--next|--prev}" >&2
    exit 1
    ;;
esac
