#!/bin/bash
# Reset terminal to black background, white text. Kill any flash/watch processes.
pkill -f claude-red-flash 2>/dev/null
pkill -f claude-input-watch 2>/dev/null
printf '\e]11;#000000\a\e]10;#FFFFFF\a' >/dev/tty
