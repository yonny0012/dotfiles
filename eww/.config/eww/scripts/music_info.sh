#!/usr/bin/env bash
# ============================================
# Music info for Eww — MPD via mpc
# Returns semantic strings, NOT icon chars
# ============================================

COVER="/tmp/.music_cover.jpg"
COVER_SRC="/tmp/.music_cover.src"
MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"
SEP=$'\x1f'

# Extracts the cover only when the track changes; prints its path or nothing.
get_cover() {
  local current_file="$1"

  if [[ -z "$current_file" ]]; then
    echo ""
    return
  fi

  if [[ -f "$COVER" && "$(cat "$COVER_SRC" 2>/dev/null)" == "$current_file" ]]; then
    echo "$COVER"
    return
  fi

  if ffmpeg -i "${MUSIC_DIR}/${current_file}" "${COVER}" -y &>/dev/null; then
    printf '%s' "$current_file" >"$COVER_SRC"
    echo "$COVER"
  else
    rm -f "$COVER_SRC"
    echo ""
  fi
}

# One JSON object with everything the widget needs, from two mpc calls.
get_all() {
  local status_out state="stopped" progress=0 ctime="0:00"
  local song artist ttime file

  status_out="$(mpc status 2>/dev/null)"
  if [[ $status_out == *"[playing]"* ]]; then
    state="playing"
  elif [[ $status_out == *"[paused]"* ]]; then
    state="paused"
  fi

  if [[ $status_out =~ ([0-9:]+)/[0-9:]+\ +\(([0-9]+)%\) ]]; then
    ctime="${BASH_REMATCH[1]}"
    progress="${BASH_REMATCH[2]}"
  fi

  IFS="$SEP" read -r song artist ttime file \
    < <(mpc -f "%title%${SEP}%artist%${SEP}%time%${SEP}%file%" current 2>/dev/null)

  jq -cn \
    --arg status "$state" \
    --arg song "${song:-Offline}" \
    --arg artist "${artist:-Offline}" \
    --argjson progress "$progress" \
    --arg ctime "$ctime" \
    --arg ttime "${ttime:-0:00}" \
    --arg cover "$(get_cover "$file")" \
    '{status: $status, song: $song, artist: $artist, progress: $progress,
      ctime: $ctime, ttime: $ttime, cover: $cover}'
}

case "$1" in
  --all)     get_all ;;
  --toggle)  mpc -q toggle ;;
  --next)    mpc -q next ;;
  --prev)    mpc -q prev ;;
  *)
    echo "Usage: $0 {--all|--toggle|--next|--prev}" >&2
    exit 1
    ;;
esac
