#!/bin/sh

/sbin/gtklock -d --time-format "%H:%M" --date-format "%A, %d.%m.%Y" -s $HOME/.config/gtklock/andro/style.css
[ "$1" = "suspend" ] && /sbin/systemctl suspend
