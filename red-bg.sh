#!/bin/bash
# Flash terminal background red/dark until any HID input (mouse/keyboard),
# then settle on solid dark red. Uses ioreg HIDIdleTime (no permissions needed).
#
# Remaps ALL 16 ANSI palette colors to light versions readable on #3D1111.
# Also handles apps using true color by setting the default foreground.

ESC=$'\e'
BEL=$'\a'

# Light palette: all colors readable on dark red (#3D1111)
# Colors 0-7 (normal) remapped to bright/pastel versions
# Colors 8-15 (bright) also remapped to ensure contrast
LIGHT=""
LIGHT+="${ESC}]10;#F0F0F0${BEL}"          # default foreground
LIGHT+="${ESC}]4;0;#C8B8B8${BEL}"          # black   → warm grey
LIGHT+="${ESC}]4;1;#FF8A80${BEL}"          # red     → light red
LIGHT+="${ESC}]4;2;#69F0AE${BEL}"          # green   → light green
LIGHT+="${ESC}]4;3;#FFD740${BEL}"          # yellow  → light amber
LIGHT+="${ESC}]4;4;#82B1FF${BEL}"          # blue    → light blue
LIGHT+="${ESC}]4;5;#EA80FC${BEL}"          # magenta → light purple
LIGHT+="${ESC}]4;6;#84FFFF${BEL}"          # cyan    → light cyan
LIGHT+="${ESC}]4;7;#F5F5F5${BEL}"          # white   → bright white
LIGHT+="${ESC}]4;8;#D0C0C0${BEL}"          # bright black   → lighter grey
LIGHT+="${ESC}]4;9;#FF8A80${BEL}"          # bright red     → light red
LIGHT+="${ESC}]4;10;#69F0AE${BEL}"         # bright green   → light green
LIGHT+="${ESC}]4;11;#FFD740${BEL}"         # bright yellow  → light amber
LIGHT+="${ESC}]4;12;#82B1FF${BEL}"         # bright blue    → light blue
LIGHT+="${ESC}]4;13;#EA80FC${BEL}"         # bright magenta → light purple
LIGHT+="${ESC}]4;14;#84FFFF${BEL}"         # bright cyan    → light cyan
LIGHT+="${ESC}]4;15;#FFFFFF${BEL}"         # bright white   → white

RED_BG="${ESC}]11;#3D1111${BEL}"
BLK_BG="${ESC}]11;#000000${BEL}"

pkill -f kiro-red-flash 2>/dev/null
pkill -f kiro-input-watch 2>/dev/null

# Record idle time at launch — any new input will make it drop
IDLE_AT_START=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

# Write escape sequences to temp files so subshells can cat them
TMPF=$(mktemp /tmp/claude-flash.XXXXXX)
printf '%s' "${RED_BG}${LIGHT}" > "${TMPF}.red"
printf '%s' "${BLK_BG}${LIGHT}" > "${TMPF}.blk"
printf '%s' "${RED_BG}${LIGHT}" > "${TMPF}.settle"

# Start the flash loop as a named process
nohup bash -c "exec -a kiro-red-flash bash -c '
while true; do
  cat \"${TMPF}.red\" >/dev/tty
  sleep 0.5
  cat \"${TMPF}.blk\" >/dev/tty
  sleep 0.5
done
'" >/dev/null 2>&1 &
disown

# Poll HIDIdleTime — when it drops below the start value, user touched something
nohup bash -c "exec -a kiro-input-watch bash -c '
START=${IDLE_AT_START}
while true; do
  sleep 0.15
  NOW=\$(ioreg -c IOHIDSystem | awk \"/HIDIdleTime/ {print \\\$NF; exit}\")
  if [ \"\$NOW\" -lt \"\$START\" ]; then
    pkill -f kiro-red-flash 2>/dev/null
    cat \"${TMPF}.settle\" >/dev/tty
    rm -f \"${TMPF}\" \"${TMPF}.red\" \"${TMPF}.blk\" \"${TMPF}.settle\" 2>/dev/null
    exit 0
  fi
done
'" >/dev/null 2>&1 &
disown
