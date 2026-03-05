#!/bin/bash
# Flash terminal background red/dark until any HID input (mouse/keyboard),
# then settle on solid dark red. Uses ioreg HIDIdleTime (no permissions needed).

pkill -f claude-red-flash 2>/dev/null
pkill -f claude-input-watch 2>/dev/null

# Record idle time at launch — any new input will make it drop
IDLE_AT_START=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

# Start the flash loop as a named process
nohup bash -c 'exec -a claude-red-flash bash -c '"'"'
while true; do
  printf "\e]11;#3D1111\a\e]10;#FFFFFF\a" >/dev/tty
  sleep 0.5
  printf "\e]11;#000000\a\e]10;#FFFFFF\a" >/dev/tty
  sleep 0.5
done
'"'"'' >/dev/null 2>&1 &
disown

# Poll HIDIdleTime — when it drops below the start value, user touched something
nohup bash -c 'exec -a claude-input-watch bash -c '"'"'
START='"$IDLE_AT_START"'
while true; do
  sleep 0.15
  NOW=$(ioreg -c IOHIDSystem | awk "/HIDIdleTime/ {print \$NF; exit}")
  if [ "$NOW" -lt "$START" ]; then
    pkill -f claude-red-flash 2>/dev/null
    printf "\e]11;#3D1111\a\e]10;#FFFFFF\a" >/dev/tty
    exit 0
  fi
done
'"'"'' >/dev/null 2>&1 &
disown
