#!/usr/bin/env bash
# requires: acpilight
# optional: libnotify (notify-send)

increase() {
    if [ "$(xbacklight -get)" -eq 100 ]; then
	notify-send -t 500 "Maximum brightness [$(xbacklight -get)%] "
    elif [ "$(xbacklight -get)" -eq 1 ]; then
	xbacklight -set 5 -steps 25
    elif [ "$(xbacklight -get)" -lt 30 ]; then
	xbacklight -inc 5 -steps 25
    else
	xbacklight -inc 10 -steps 25
    fi
}

decrease() {
    if [ "$(xbacklight -get)" -le 1 ]; then
	xbacklight -set 1
	notify-send -t 500 "Minimum brightness [$(xbacklight -get)%]"
    elif [ "$(xbacklight -get)" -le 5 ]; then
	xbacklight -set 1 -steps 25
    elif [ "$(xbacklight -get)" -le 30 ]; then
	xbacklight -dec 5 -steps 25
    else
	xbacklight -dec 10 -steps 25
    fi
}

print-usage() {
    echo "usage: $(basename "$0") [ increase | decrease | help ]"
}


if [[ $# -eq 0 ]]; then
    echo "no arguments passed."
    print-usage
    exit 1
elif [[ $1 == "increase" ]]; then
    increase
elif [[ $1 == "decrease" ]]; then
    decrease
elif [[ $1 == "help" ]]; then
    print-usage
    exit
else
    echo "unknown argument passed."
    print-usage
    exit 1
fi
