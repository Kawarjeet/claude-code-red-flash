#!/bin/bash
# Reset terminal colors to defaults. Kill any flash/watch processes.
# \e]110 = reset default foreground, \e]111 = reset default background
# \e]104 (no args) = reset entire ANSI palette to defaults (includes ext colors)
pkill -f kiro-red-flash 2>/dev/null
pkill -f kiro-input-watch 2>/dev/null
printf '\e]110\a\e]111\a\e]104\a' >/dev/tty
