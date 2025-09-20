#!/bin/sh

install() {
    dotfiles_dependencies
    #generic
    #fonts
    #themes
    #drivers_amd
    #drivers_intel
    #sway
    #hyprland
    #polkit
    #wine
    #sound
    #network
    #bluetooth
    #laptop
}


aur_helper() {
    sudo pacman -Sy --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
}

generic() {
    yay -S --noconfirm --needed linux-headers bash-completion gcc gcc-libs 7z curl nano mc bc htop s-tui tmux libsensors gvfs gvfs-mtp android-udev libmtp android-tools greetd greetd-agreety fastfetch pacseek
}

fonts() {
    yay -S --noconfirm --needed ttf-firacode-nerd cantarell-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome otf-font-awesome adwaita-fonts gnu-free-fonts
}

themes() {
    yay -S --noconfirm --needed adwaita-icon-theme adwaita-icon-theme-legacy bibata-cursor-theme papirus-icon-theme nwg-look xdg-desktop-portal-gtk qt5-wayland qt5ct qt5-styleplugins qt6-wayland qt6ct gnome-themes-extra adwaita-qt5-git adwaita-qt6-git
}

drivers_amd() {
    yay -S --noconfirm --needed amd-ucode mesa lib32-mesa mesa-utils mesa-utils xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
}

drivers_intel() {
    yay -S --noconfirm --needed intel-ucode mesa lib32-mesa mesa-utils vulkan-intel lib32-vulkan-intel xf86-video-intel
}

sway() {
    yay -S --noconfirm --needed swayfx swaybg xdg-desktop-portal xorg-xwayland wev
}

hyprland() {
    yay -S --noconfirm --needed hyprland hyprutils hyprpaper swayidle xdg-desktop-portal-hyprland xorg-xwayland wev
}

polkit() {
    yay -S --noconfirm --needed --noconfirm --needed polkit polkit-gnome
}

wine() {
    yay -S --noconfirm --needed wine winetricks lutris protonup-qt-bin
}

sound() {
    yay -S --noconfirm --needed pipewire lib32-pipewire pipewire-pulse pavucontrol wireplumber
    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
}

network() {
    yay -S --noconfirm --needed inetutils iw wireless_tools net-tools networkmanager
    sudo systemctl enable NetworkManager.service
}

bluetooth() {
    yay -S --noconfirm --needed bluez bluez-libs bluez-utils blueman
}

dotfiles_dependencies() {
    yay -S --noconfirm --needed ttf-firacode-nerd cantarell-fonts rofi-wayland starship alacritty waybar dunst libnotify slurp grim gtklock playerctl python-pywal network-manager-applet wl-clipboard thunar
}

laptop() {
    yay -S --noconfirm --needed acpilight laptop-mode-tools upower powerstat powertop tuned
    sudo systemctl enable laptop-mode.service tuned.service
    sudo usermod -aG video $USER
}

print_usage() {
    echo -e "choose what to install by un/commenting options in the install() section of this script\nonce you're done, run <$(basename "$0") install> to begin installation\n"
}

su_install() {
    sudo -v
    while true; do
       sleep 60
       sudo -n true
    done &
    sudo_session_pid=$!
    install
    kill $sudo_session_pid
}

if [[ $# -eq 0 ]]; then
    echo "no arguments passed."
    print_usage
    exit 1
elif [[ $1 == "install" ]]; then
    if ! command -v "yay" >/dev/null 2>&1; then
       aur_helper
    fi
    yay -Sy --save --answerclean None --answerdiff None --noansweredit None --noconfirm --removemake
    su_install
    yay -Sy --save --noanswerclean --noanswerdiff --noansweredit --askremovemake > /dev/null 2>&1
    exit
elif [[ $1 == "install-dependencies" ]]; then
    if ! command -v "yay" >/dev/null 2>&1; then
       aur_helper
    fi
    yay -Sy --save --answerclean --answerdiff --noansweredit --noconfirm --removemake > /dev/null 2>&1
    dotfiles_dependencies
    yay -Sy --save --noanswerclean --noanswerdiff --noansweredit --askremovemake > /dev/null 2>&1
    exit
elif [[ $1 == "help" ]]; then
    print_usage
    exit
else
    echo "unknown argument passed."
    print_usage
    exit 1
fi
