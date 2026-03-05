#!/bin/bash
# Reset terminal colors to defaults. Kill any flash/watch processes.
# \e]110 = reset default foreground, \e]111 = reset default background
# \e]104;0 and \e]104;8 = reset ANSI palette colors 0 and 8
pkill -f claude-red-flash 2>/dev/null
pkill -f claude-input-watch 2>/dev/null
printf '\e]110\a\e]111\a\e]104;0\a\e]104;8\a' >/dev/tty
rm -f /tmp/claude-flash.* 2>/dev/null
