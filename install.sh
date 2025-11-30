#!/usr/bin/env bash

config="$HOME/.config"
share="$HOME/.local/share"
dotfiles="$(cd "$(dirname "$0")" && pwd)"

if [ "$1" == "copy" ]; then
    action=(cp -r)
elif [ "$1" == "symlink" ]; then
    action=(ln -snf)
fi

mkdir -p "$config"
mkdir -p "$share"

find "$dotfiles" -type f -name "*.sh" -exec chmod +x {} +

echo -e "
export XCURSOR_SIZE=22
export XDG_CURRENT_DESKTOP=Sway
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Sway
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export MOZ_ENABLE_WAYLAND=1
export GDK_SCALE=1
export QT_QPA_PLATFORMTHEME=qt5ct
export WLR_NO_HARDWARE_CURSORS=1
export PATH="$HOME/.local/bin:$PATH"
$HOME/.config/andro/scripts/wm/env/gsettings.sh
" >> $HOME/.profile
echo "[w] --> $HOME/.profile"

echo 'if command -v starship &> /dev/null; then eval "$(starship init bash)"; fi' >> "$HOME/.bashrc" && echo "[w] --> $HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && echo 'if command -v starship &> /dev/null; then eval "$(starship init zsh)"; fi' >> "$HOME/.zshrc" && echo "[w] --> $HOME/.zshrc"

backup() {
    if [ -e "$target_dir" ]; then
        local i=1
        local backup_dir="${target_dir}.bak"
        while [ -e "$backup_dir" ]; do
            backup_dir="${target_dir}.$i.bak"
            i=$((i+1))
        done
        echo -e "\n[!] $target_dir already exists"
        echo -e "[+] $target_dir --> $backup_dir"
        mv "$target_dir" "$backup_dir"
    fi
}

symlink() {
    local source_dir="$1"
    local target_dir="$2"
    mkdir -p "$(dirname "$target_dir")"
    backup
    echo -e "[+] $source_dir --> $target_dir"
    "${action[@]}" "$source_dir" "$target_dir"
}

for dotfiles_directory in "$dotfiles"/*; do
    [ -d "$dotfiles_directory" ] || continue
    dirname=$(basename "$dotfiles_directory")
    symlink "$dotfiles_directory" "$config/$dirname"
done

action=(ln -snf)
symlink "$config/andro/scripts/wm" "$config/hypr/scripts"
symlink "$config/andro/scripts/wm" "$config/sway/scripts"
mkdir -p "$HOME/Pictures"
symlink "$dotfiles/andro/wallpapers" "$HOME/Pictures/wallpapers"
mkdir -p "$HOME/.local/bin"
symlink "$config/andro/scripts/wm/waybar-theme.sh" "$HOME/.local/bin/waybar-theme"
symlink "$config/andro/scripts/wm/wallpaper.sh" "$HOME/.local/bin/wallpaper"

$dotfiles/pacstrap.sh install-dependencies
$config/andro/scripts/wm/env/gsettings.sh
$config/andro/scripts/wm/wallpaper.sh set random
$config/andro/scripts/wm/waybar-theme.sh set andro/simple
