#!/bin/bash
# Reset terminal colors to defaults. Kill any flash/watch processes.
pkill -f claude-red-flash 2>/dev/null
pkill -f claude-input-watch 2>/dev/null
printf '\e]110\a\e]111\a' >/dev/tty
