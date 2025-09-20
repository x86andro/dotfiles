#!/bin/sh
action="$1"
wallpaper="$2"
wallpaper_dir="$HOME/Pictures/wallpapers"
waybar_override_file="$HOME/.config/waybar/andro/override.css"
debug=false


set_hypr() {
    hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"
    echo "preload = $wallpaper" > "$hyprpaper_conf"
    echo "wallpaper = ,$wallpaper" >> "$hyprpaper_conf"
    generate_palette
    load_hypr
}

load_hypr() {
    if pgrep -x "hyprpaper" > /dev/null; then
        hyprctl hyprpaper reload ,"$wallpaper"
    else
        hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"
        hyprctl hyprpaper preload "$hyprpaper_conf"
        hyprctl hyprpaper wallpaper ",$hyprpaper_conf"
        hyprpaper --config "$hyprpaper_conf" &
    fi
}

set_temp_hypr() {
    if pgrep -x "hyprpaper" > /dev/null; then
        hyprctl hyprpaper reload ,"$wallpaper"
    else
        temp_hyprpaper_file="/tmp/temp_hyprpaper.conf"
        rm "$temp_hyprpaper_file" > /dev/null 2>&1
        echo "preload '$wallpaper'" > "$temp_hyprpaper_file"
        echo "wallpaper '$wallpaper'" >> "$temp_hyprpaper_file"
        hyprpaper --config "$temp_hyprpaper_file" &
        rm "$temp_hyprpaper_file" > /dev/null 2>&1
        sleep 0.25
        hyprctl hyprpaper reload ,"$wallpaper"
    fi
}

set_sway() {
    echo "$wallpaper" > "$HOME/.config/sway/swaybg.ini"
    echo "[w] $HOME/.config/sway/swaybg.ini"
    generate_palette
    load_sway
}

load_sway() {
    wallpaper="$(cat "$HOME/.config/sway/swaybg.ini")"

    if $debug; then
        swaybg -i "$wallpaper" -m fill &
    else
        swaybg -i "$wallpaper" -m fill > /dev/null 2>&1 &
    fi

    sleep 0.5
    pkill swaybg
    swaybg -i "$wallpaper" -m fill &
}

set_temp_sway() {
    pkill swaybg

    if $debug; then
        swaybg -i "$wallpaper" -m fill &
    else
        swaybg -i "$wallpaper" -m fill > /dev/null 2>&1 &
    fi
}

generate_palette() {
    source $HOME/.config/andro/scripts/wm/wallpaper-brightness.sh $wallpaper $waybar_override_file

    if $debug; then
        wal -i "$wallpaper"
    else
        wal -i "$wallpaper" > /dev/null 2>&1
    fi
    echo "[w] $HOME/.cache/wal/"*""
    echo "[+] color palette generated"
    #source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/wallpaper-brightness.sh $wallpaper $waybar_override_file
    reload_waybar
}

reload_waybar() {
    $HOME/.config/andro/scripts/wm/waybar-theme.sh load
}

check_image_path() {
    if [ "$wallpaper_indirect" == "1" ]; then
        if [ ! -d "$wallpaper_dir" ]; then
            echo "folder $wallpaper_dir does not exist"
            exit 1
        elif [ -z "$(ls -A "$wallpaper_dir" 2>/dev/null)" ]; then
            echo "there are no wallpapers in $wallpaper_dir"
            exit 1
        fi
    fi

    image_regex=".*\.(jpg|jpeg|png|gif|bmp|tiff|webp|svg)$"
    if ! [[ "$wallpaper" =~ $image_regex ]]; then
            echo "[!] $wallpaper does not have a valid image extension."
            exit 1
    fi

    if [[ ! -f "$wallpaper" ]]; then
            echo "[!] $wallpaper does not exist."
            exit 1
    fi
}

detect_compositor() {
    if pgrep -x "Hyprland" >/dev/null; then
        compositor="hypr"
    elif pgrep -x "sway" >/dev/null; then
        compositor="sway"
    else
        echo -e "unknown compositor.\nthis script supports only hyprland and sway."
        exit 1
    fi

    if $debug; then
        echo "[d] compositor: $compositor"
    fi
}

action() {
    if [[ $action == "set" ]]; then
        set_$compositor
    elif [[ $action == "load" ]]; then
        load_$compositor
    elif [[ $action == "set-temp" ]]; then
        set_temp_$compositor
    fi
}

if [[ $debug == "true" ]]; then
        silence=" > /dev/null 2>&1"
fi

print_usage() {
    echo "usage: $(basename "$0") [ list | set <wallpaper> | set-temp <wallpaper> | set-random | load | help ]"
}


if [[ -z $@ ]]; then
    echo "no arguments passed."
    print_usage
    exit 1
elif [[ $action == "set" || $action == "set-temp" ]]; then
    if [[ ! -f "$wallpaper" ]]; then
        if [[ "$wallpaper" != */* ]]; then
            wallpaper="$wallpaper_dir/$wallpaper"
	    wallpaper_indirect=1
        fi
    fi
    check_image_path
    echo "[i] image: $wallpaper"
    detect_compositor
    action
    echo "[+] wallpaper set"
    exit
elif [[ $action == "set-random" ]]; then
    source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/wallpaper.sh set $(source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/wallpaper.sh list | sed '1d;$d' | shuf -n 1)
    exit
elif [[ $action == "load" ]]; then
    echo "[i] image: $wallpaper"
    detect_compositor
    action
    exit
elif [[ $action == "list" ]]; then
    echo ""
    if [ -d "$wallpaper_dir" ]; then
        if ! ls -1 "$wallpaper_dir" | grep -Ei "\.(jpg|jpeg|png|gif|bmp|tiff|webp|svg)$" | sort | grep -q .; then
            echo "there are no wallpapers in $wallpaper_dir"
            exit 1
        fi
        ls -1 "$wallpaper_dir" | grep -Ei "\.(jpg|jpeg|png|gif|bmp|tiff|webp|svg)$" | sort
        exit 0
    fi
elif [[ $action == "help" ]]; then
    print_usage
    echo -e "help - shows this menu\n\
list - list all images in the <wallpapers> directory\n\
set <wallpaper> - set a wallpaper for this compositor\n\
set-temp <wallpaper> - load a wallpaper temporarily without modifying the configuration file\n\
set-random - sets a random wallpaper for this compositor\n\
load - loads the currently set wallpaper for the compositor (intended for use when starting the compositor)\n\n\
you can specify images by providing a full path to them, or by name only (e.g. image.png) if they are in the <wallpapers> directory.\n\
the path to the <wallpapers> directory can be configured in this script.\n\
this script works only with hyprland and sway."
    exit 0
else
    echo "unknown argument passed."
    print_usage
    exit 1
fi
