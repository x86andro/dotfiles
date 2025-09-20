#!/bin/sh
action="$1"
theme_name="$2"
config="config"
css="style.css"
debug=false


resolve() {
    theme="$HOME/.config/waybar/$theme_name"
    if [ -d "$theme" ]; then
        echo "[i] theme: $theme"
    else
        echo "[!] theme $theme_name not found in $HOME/.config/waybar directory."
        exit 1
    fi
}

set_theme() {
    echo "$theme" > "$HOME/.config/waybar/waybar.ini"
    echo "[w] $HOME/.config/waybar/waybar.ini"
}

load_theme() {
    killall waybar
    sleep 0.25
    if $debug; then
        waybar -c "$theme/$config" -s "$theme/$css" &
    else
        waybar -c "$theme/$config" -s "$theme/$css" > /dev/null 2>&1 &
    fi

    if pgrep -x "Hyprland" >/dev/null; then
        sleep 0.2
        hyprctl reload & > /dev/null 2>&1
        sleep 1.3
        hyprctl reload & > /dev/null 2>&1
    fi
    echo "[+] waybar loaded"
    exit
}

print_usage() {
    echo "usage: $0 [ help | list | load | set <theme> | set-temp <theme> ]"
}


if [[ -z $@ ]]; then
    echo "no arguments passed."
    print_usage
    exit 1
elif [[ $action == "list" ]]; then
    find -L "$HOME/.config/waybar/" -maxdepth 2 -type d -exec sh -c '[ -f "$1/config" ] && [ -f "$1/style.css" ] && printf "%s\n" "${1#"$HOME/.config/waybar/"}"' _ {} \; | sort
    exit 0
elif [[ $action == "load" ]]; then
    theme="$(cat "$HOME/.config/waybar/waybar.ini")"
    load_theme
elif [[ $action == "set" ]]; then
    resolve
    set_theme
    load_theme
elif [[ $action == "set-temp" ]]; then
    resolve
    load_theme
elif [[ $action == "help" ]]; then
    print_usage
else
    echo "unknown argument passed."
    print_usage
    exit 1
fi
