#!/bin/bash
# Flash terminal background red/dark until any HID input (mouse/keyboard),
# then settle on solid dark red. Uses ioreg HIDIdleTime (no permissions needed).
#
# Color strategy (WCAG AAA compliant against #3D1111):
#   Default text:   #F0F0F0 (off-white, ~18:1 contrast)
#   ANSI black (0): #C8B8B8 (warm grey, ~11:1 contrast)
#   ANSI bright black (8): #D0C0C0 (lighter warm grey, ~13:1 contrast)
# This ensures ALL terminal text is readable on dark red, including text
# explicitly colored black/dark-grey by the application.

ESC=$'\e'
BEL=$'\a'
LIGHT="${ESC}]10;#F0F0F0${BEL}${ESC}]4;0;#C8B8B8${BEL}${ESC}]4;8;#D0C0C0${BEL}"
RED_BG="${ESC}]11;#3D1111${BEL}"
BLK_BG="${ESC}]11;#000000${BEL}"

pkill -f claude-red-flash 2>/dev/null
pkill -f claude-input-watch 2>/dev/null

# Record idle time at launch — any new input will make it drop
IDLE_AT_START=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

# Write escape sequences to a temp file so subshells can read them without quoting issues
TMPF=$(mktemp /tmp/claude-flash.XXXXXX)
printf '%s' "${RED_BG}${LIGHT}" > "${TMPF}.red"
printf '%s' "${BLK_BG}${LIGHT}" > "${TMPF}.blk"
printf '%s' "${RED_BG}${LIGHT}" > "${TMPF}.settle"

# Start the flash loop as a named process
nohup bash -c "exec -a claude-red-flash bash -c '
while true; do
  cat \"${TMPF}.red\" >/dev/tty
  sleep 0.5
  cat \"${TMPF}.blk\" >/dev/tty
  sleep 0.5
done
'" >/dev/null 2>&1 &
disown

# Poll HIDIdleTime — when it drops below the start value, user touched something
nohup bash -c "exec -a claude-input-watch bash -c '
START=${IDLE_AT_START}
while true; do
  sleep 0.15
  NOW=\$(ioreg -c IOHIDSystem | awk \"/HIDIdleTime/ {print \\\$NF; exit}\")
  if [ \"\$NOW\" -lt \"\$START\" ]; then
    pkill -f claude-red-flash 2>/dev/null
    cat \"${TMPF}.settle\" >/dev/tty
    rm -f \"${TMPF}\" \"${TMPF}.red\" \"${TMPF}.blk\" \"${TMPF}.settle\" 2>/dev/null
    exit 0
  fi
done
'" >/dev/null 2>&1 &
disown
