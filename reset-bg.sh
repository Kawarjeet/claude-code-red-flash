#!/bin/bash
# Reset to white background with dark palette colors.
# Remaps all 16 ANSI colors + extended to dark tones readable on white bg.
pkill -f kiro-red-flash 2>/dev/null
pkill -f kiro-input-watch 2>/dev/null

ESC=$'\e'
BEL=$'\a'

P=""
P+="${ESC}]11;#FFFFFF${BEL}"          # background -> white
P+="${ESC}]10;#1A1A2E${BEL}"          # default foreground -> dark charcoal
P+="${ESC}]4;0;#333333${BEL}"          # black   -> dark grey
P+="${ESC}]4;1;#C62828${BEL}"          # red     -> deep red
P+="${ESC}]4;2;#2E7D32${BEL}"          # green   -> forest green
P+="${ESC}]4;3;#F57F17${BEL}"          # yellow  -> dark amber
P+="${ESC}]4;4;#1565C0${BEL}"          # blue    -> strong blue
P+="${ESC}]4;5;#7B1FA2${BEL}"          # magenta -> deep purple
P+="${ESC}]4;6;#00838F${BEL}"          # cyan    -> dark teal
P+="${ESC}]4;7;#3A3A3A${BEL}"          # white   -> dark grey (key fix)
P+="${ESC}]4;8;#555555${BEL}"          # bright black   -> medium grey
P+="${ESC}]4;9;#D32F2F${BEL}"          # bright red     -> medium red
P+="${ESC}]4;10;#388E3C${BEL}"         # bright green   -> medium green
P+="${ESC}]4;11;#F9A825${BEL}"         # bright yellow  -> amber
P+="${ESC}]4;12;#1976D2${BEL}"         # bright blue    -> medium blue
P+="${ESC}]4;13;#8E24AA${BEL}"         # bright magenta -> medium purple
P+="${ESC}]4;14;#00979D${BEL}"         # bright cyan    -> medium teal
P+="${ESC}]4;15;#4A4A4A${BEL}"         # bright white   -> medium grey (key fix)
P+="${ESC}]4;38;#1565C0${BEL}"         # ext 38  -> strong blue
P+="${ESC}]4;206;#AD1457${BEL}"        # ext 206 -> deep pink

printf '%s' "$P" >/dev/tty
