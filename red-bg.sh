#!/bin/bash
# Flash terminal background red/dark until any HID input (mouse/keyboard),
# then settle on solid dark red. Uses ioreg HIDIdleTime (no permissions needed).
#
# Remaps ALL 16 ANSI palette colors + extended colors 38 & 206 to light
# versions readable on dark red (#3D1111). All WCAG AAA compliant.

ESC=$'\e'
BEL=$'\a'

# Build palette remap: all colors light enough for dark red background
P=""
P+="${ESC}]10;#F0F0F0${BEL}"          # default foreground → off-white
P+="${ESC}]4;0;#C8B8B8${BEL}"          # black   → warm grey
P+="${ESC}]4;1;#FF8A80${BEL}"          # red     → light red
P+="${ESC}]4;2;#69F0AE${BEL}"          # green   → light green
P+="${ESC}]4;3;#FFD740${BEL}"          # yellow  → light amber
P+="${ESC}]4;4;#82B1FF${BEL}"          # blue    → light blue
P+="${ESC}]4;5;#EA80FC${BEL}"          # magenta → light purple
P+="${ESC}]4;6;#84FFFF${BEL}"          # cyan    → light cyan
P+="${ESC}]4;7;#F5F5F5${BEL}"          # white   → bright white
P+="${ESC}]4;8;#D0C0C0${BEL}"          # bright black   → lighter grey
P+="${ESC}]4;9;#FF8A80${BEL}"          # bright red     → light red
P+="${ESC}]4;10;#69F0AE${BEL}"         # bright green   → light green
P+="${ESC}]4;11;#FFD740${BEL}"         # bright yellow  → light amber
P+="${ESC}]4;12;#82B1FF${BEL}"         # bright blue    → light blue
P+="${ESC}]4;13;#EA80FC${BEL}"         # bright magenta → light purple
P+="${ESC}]4;14;#84FFFF${BEL}"         # bright cyan    → light cyan
P+="${ESC}]4;15;#FFFFFF${BEL}"         # bright white   → white
P+="${ESC}]4;38;#82B1FF${BEL}"         # ext 38  → light blue
P+="${ESC}]4;206;#FF80AB${BEL}"        # ext 206 → light pink

RED_FRAME="${ESC}]11;#3D1111${BEL}${P}"
BLK_FRAME="${ESC}]11;#000000${BEL}${P}"
SETTLE="${ESC}]11;#3D1111${BEL}${P}"

pkill -f kiro-red-flash 2>/dev/null
pkill -f kiro-input-watch 2>/dev/null

# Record idle time at launch — any new input will make it drop
IDLE_AT_START=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

# Export pre-built escape sequences so subshells inherit them
export RED_FRAME BLK_FRAME SETTLE

# Start the flash loop as a named process
nohup bash -c 'exec -a kiro-red-flash bash -c '\''
while true; do
  printf "%s" "$RED_FRAME" >/dev/tty
  sleep 0.5
  printf "%s" "$BLK_FRAME" >/dev/tty
  sleep 0.5
done
'\''' >/dev/null 2>&1 &
disown

# Poll HIDIdleTime — when it drops below the start value, user touched something
export IDLE_AT_START
nohup bash -c 'exec -a kiro-input-watch bash -c '\''
while true; do
  sleep 0.15
  NOW=$(ioreg -c IOHIDSystem | awk "/HIDIdleTime/ {print \$NF; exit}")
  if [ "$NOW" -lt "$IDLE_AT_START" ]; then
    pkill -f kiro-red-flash 2>/dev/null
    printf "%s" "$SETTLE" >/dev/tty
    exit 0
  fi
done
'\''' >/dev/null 2>&1 &
disown
