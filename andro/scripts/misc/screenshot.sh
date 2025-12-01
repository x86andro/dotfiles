#!/usr/bin/env bash
# requires: slurp, grim, wl-clipboard (wl-copy)
# optional: libnotify (notify-send), gimp

dir="$HOME/Pictures/screenshots/"
name="screenshot_$(date +%d%m%Y_%H%M%S).png"

mkdir -p $dir

all_screens() {
    grim "$dir$name"
    cat "$dir$name" | wl-copy --type image/png
    notify-send "Screenshot created and copied to clipboard"
    gimp "$dir$name" &
    exit
}

area() {
    grim -g "$(slurp)" "$dir$name"
    cat "$dir$name" | wl-copy --type image/png
    exit
}

print_usage() {
    echo "usage: $0 [ all | area | help ]"
}

if [[ $# -eq 0 ]]; then
    echo "no arguments passed."
    print_usage
    exit 1
elif [[ $1 == "all" ]]; then
    all_screens
elif [[ $1 == "area" ]]; then
    area
elif [[ $1 == "help" ]]; then
    print_usage
    exit
else
    echo "unknown argument passed."
    print_usage
    exit 1
fi
