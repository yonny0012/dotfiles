#!/usr/bin/env bash
# ============================================
# Ends the Hyprland session (dashboard logout button)
# With a Lua config, `hyprctl dispatch` takes a Lua expression
# instead of the old `dispatch exit` form.
# ============================================

hyprctl dispatch 'hl.dsp.exit()' || loginctl terminate-user "$USER"
