#!/bin/sh

$(which gtklock) -d --time-format "%l:%M %p" --date-format "%A, %d.%m.%Y" -s $HOME/.config/gtklock/andro/style.css
[ "$1" = "suspend" ] && /sbin/systemctl suspend
