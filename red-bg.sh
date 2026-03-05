#!/bin/bash
# Flash terminal background green/dark until any HID input (mouse/keyboard),
# then settle on solid light green.
#
# Light green (#C8E6C9) — easiest color for human eyes:
#   - Green sits at peak cone sensitivity, least effort to process
#   - Light pastel = low saturation, minimal fatigue
#   - ~10:1 contrast with dark text (#1B2E1B)
#   - True-color black text is perfectly readable on light bg

ESC=$'\e'
BEL=$'\a'

# --- Light mint green: gentle on eyes, clear "done" signal ---
BG_GREEN="#C8E6C9"
BG_DARK="#1A331A"

# Palette remap: dark tones readable on light green background
P=""
P+="${ESC}]10;#1B2E1B${BEL}"          # default foreground -> dark forest
P+="${ESC}]4;0;#2E4A2E${BEL}"          # black   -> dark green-grey
P+="${ESC}]4;1;#9B2335${BEL}"          # red     -> deep crimson
P+="${ESC}]4;2;#2E7D32${BEL}"          # green   -> forest green
P+="${ESC}]4;3;#8B6914${BEL}"          # yellow  -> dark gold
P+="${ESC}]4;4;#1565C0${BEL}"          # blue    -> strong blue
P+="${ESC}]4;5;#7B1FA2${BEL}"          # magenta -> deep purple
P+="${ESC}]4;6;#00838F${BEL}"          # cyan    -> dark teal
P+="${ESC}]4;7;#1B2E1B${BEL}"          # white   -> dark forest
P+="${ESC}]4;8;#3E5A3E${BEL}"          # bright black   -> medium green-grey
P+="${ESC}]4;9;#C62828${BEL}"          # bright red     -> medium red
P+="${ESC}]4;10;#388E3C${BEL}"         # bright green   -> medium green
P+="${ESC}]4;11;#F9A825${BEL}"         # bright yellow  -> amber
P+="${ESC}]4;12;#1976D2${BEL}"         # bright blue    -> medium blue
P+="${ESC}]4;13;#8E24AA${BEL}"         # bright magenta -> medium purple
P+="${ESC}]4;14;#00979D${BEL}"         # bright cyan    -> medium teal
P+="${ESC}]4;15;#2E4A2E${BEL}"         # bright white   -> dark green-grey
P+="${ESC}]4;38;#1565C0${BEL}"         # ext 38  -> strong blue
P+="${ESC}]4;206;#AD1457${BEL}"        # ext 206 -> deep pink

pkill -f kiro-red-flash 2>/dev/null
pkill -f kiro-input-watch 2>/dev/null

# Record idle time at launch
IDLE_AT_START=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

# Write escape sequences to temp files (avoids nested-quoting issues)
TMPDIR_FLASH=$(mktemp -d)
printf '%s' "${ESC}]11;${BG_GREEN}${BEL}${P}" > "$TMPDIR_FLASH/red"
printf '%s' "${ESC}]11;${BG_DARK}${BEL}${P}" > "$TMPDIR_FLASH/blk"
printf '%s' "${ESC}]11;${BG_GREEN}${BEL}${P}" > "$TMPDIR_FLASH/settle"

# Flash loop script
cat > "$TMPDIR_FLASH/flash.sh" << 'SCRIPT'
#!/bin/bash
DIR="$1"
while true; do
  cat "$DIR/red" >/dev/tty
  sleep 0.5
  cat "$DIR/blk" >/dev/tty
  sleep 0.5
done
SCRIPT

# Input watch script
cat > "$TMPDIR_FLASH/watch.sh" << SCRIPT
#!/bin/bash
DIR="$TMPDIR_FLASH"
IDLE_AT_START=$IDLE_AT_START
while true; do
  sleep 0.15
  NOW=\$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print \$NF; exit}')
  if [ "\$NOW" -lt "\$IDLE_AT_START" ]; then
    pkill -f kiro-red-flash 2>/dev/null
    cat "$TMPDIR_FLASH/settle" >/dev/tty
    exit 0
  fi
done
SCRIPT

chmod +x "$TMPDIR_FLASH/flash.sh" "$TMPDIR_FLASH/watch.sh"

# Start flash loop
nohup bash -c "exec -a kiro-red-flash bash '$TMPDIR_FLASH/flash.sh' '$TMPDIR_FLASH'" >/dev/null 2>&1 &
disown

# Start input watcher
nohup bash -c "exec -a kiro-input-watch bash '$TMPDIR_FLASH/watch.sh'" >/dev/null 2>&1 &
disown
