#!/bin/sh

config="$HOME/.config"
share="$HOME/.local/share"

dotfiles="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$config"
mkdir -p "$share"

find "$dotfiles" -type f -name "*.sh" -print0 | xargs -0 chmod +x

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
    ln -snf "$source_dir" "$target_dir"
}

for dotfiles_directory in "$dotfiles"/*; do
  [ -d "$dotfiles_directory" ] || continue
  dirname=$(basename "$dotfiles_directory")

[[ $dirname =~ ^(hypr|icons|wal|rofi|andro|sway|Thunar)$ ]] && continue

  if [ -d "$dotfiles_directory/andro" ]; then
      symlink "$dotfiles/$dirname/andro" "$config/$dirname/andro"
  else
      symlink "$dotfiles_directory" "$config/$dirname"
  fi
done

symlink "$dotfiles/andro" "$config/andro"
symlink "$dotfiles/hypr/hyprland.conf" "$config/hypr/hyprland.conf"
symlink "$dotfiles/hypr/andro" "$config/hypr/andro"
symlink "$dotfiles/andro/scripts/wm" "$config/hypr/scripts"
symlink "$dotfiles/sway/config" "$config/sway/config"
symlink "$dotfiles/andro/scripts/wm" "$config/sway/scripts"
symlink "$dotfiles/icons/default/index.theme" "$share/icons/default/index.theme"
symlink "$dotfiles/wal/templates/colors-hyprland.conf" "$config/wal/templates/colors-hyprland.conf"
symlink "$dotfiles/rofi/config.rasi" "$config/rofi/config.rasi"
symlink "$dotfiles/rofi/themes/andro.rasi" "$config/rofi/themes/andro.rasi"
cp -r "$dotfiles/Thunar" "$config"

mkdir -p "$HOME/Pictures"
symlink "$dotfiles/andro/wallpapers" "$HOME/Pictures/wallpapers"

mkdir -p "$HOME/.local/bin"
symlink "$dotfiles/andro/scripts/wm/waybar-theme.sh" "$HOME/.local/bin/waybar-theme"
symlink "$dotfiles/andro/scripts/wm/wallpaper.sh" "$HOME/.local/bin/wallpaper"

$dotfiles/andro/scripts/wm/waybar-theme.sh set andro/simple
$dotfiles/pacstrap.sh install-dependencies
$dotfiles/andro/scripts/wm/env/gsettings.sh
